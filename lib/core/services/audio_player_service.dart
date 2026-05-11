import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../features/archive/data/models/track_model.dart';
import '../constants/app_constants.dart';
import 'api_service.dart';

// Use PlayerRepeatMode to avoid conflict with Flutter's built-in RepeatMode
enum PlayerRepeatMode { none, one, all }

// ─── State Model ─────────────────────────────────────────────────────────────
class PlayerStateModel {
  final TrackModel? currentTrack;
  final List<TrackModel> queue;
  final int queueIndex;
  final bool isPlaying;
  final bool isLoading;
  final Duration position;
  final Duration duration;
  final PlayerRepeatMode repeatMode;
  final bool shuffleEnabled;
  final List<int> shuffleOrder;
  final String? error;

  const PlayerStateModel({
    this.currentTrack,
    this.queue = const [],
    this.queueIndex = 0,
    this.isPlaying = false,
    this.isLoading = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.repeatMode = PlayerRepeatMode.none,
    this.shuffleEnabled = false,
    this.shuffleOrder = const [],
    this.error,
  });

  bool get hasTrack => currentTrack != null;

  double get progress =>
      duration.inMilliseconds > 0
          ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
          : 0.0;

  String get positionStr => _format(position);
  String get durationStr => _format(duration);

  static String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  PlayerStateModel copyWith({
    TrackModel? currentTrack,
    List<TrackModel>? queue,
    int? queueIndex,
    bool? isPlaying,
    bool? isLoading,
    Duration? position,
    Duration? duration,
    PlayerRepeatMode? repeatMode,
    bool? shuffleEnabled,
    List<int>? shuffleOrder,
    String? error,
    bool clearTrack = false,
    bool clearError = false,
  }) {
    return PlayerStateModel(
      currentTrack: clearTrack ? null : (currentTrack ?? this.currentTrack),
      queue: queue ?? this.queue,
      queueIndex: queueIndex ?? this.queueIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      repeatMode: repeatMode ?? this.repeatMode,
      shuffleEnabled: shuffleEnabled ?? this.shuffleEnabled,
      shuffleOrder: shuffleOrder ?? this.shuffleOrder,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ─── AudioPlayerNotifier ──────────────────────────────────────────────────────
class AudioPlayerNotifier extends StateNotifier<PlayerStateModel> {
  // ┌─────────────────────────────────────────────────────────────────────────┐
  // │  SINGLETON AudioPlayer — survives Hot Reload                            │
  // │  Without this, each hot reload creates a new player instance while the  │
  // │  old one keeps playing → double/triple audio bug.                       │
  // └─────────────────────────────────────────────────────────────────────────┘
  static final AudioPlayer _sharedPlayer = AudioPlayer();

  // Track active stream subscriptions so we can cancel them before re-subscribing
  final List<StreamSubscription> _subs = [];

  static const String _baseUrl = AppConstants.baseUrl;

  AudioPlayerNotifier() : super(const PlayerStateModel()) {
    // Stop any zombie audio from a previous notifier (hot reload scenario).
    // This ensures clean state — no audio without a visible mini player.
    _sharedPlayer.stop();
    _loadPreferences();
    _subscribeToPlayer();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final repeatIdx = prefs.getInt('repeatMode') ?? PlayerRepeatMode.none.index;
    final shuffle = prefs.getBool('shuffleEnabled') ?? false;

    if (mounted) {
      state = state.copyWith(
        repeatMode: PlayerRepeatMode.values[repeatIdx],
        shuffleEnabled: shuffle,
      );
    }
  }

  Future<void> _savePreference(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    }
  }

  void _subscribeToPlayer() {
    // Cancel any subscriptions from a previous notifier before adding new ones
    for (final sub in _subs) {
      sub.cancel();
    }
    _subs.clear();

    _subs.add(_sharedPlayer.positionStream.listen((pos) {
      if (mounted) state = state.copyWith(position: pos);
    }));

    _subs.add(_sharedPlayer.durationStream.listen((dur) {
      if (dur != null && mounted) state = state.copyWith(duration: dur);
    }));

    _subs.add(_sharedPlayer.playingStream.listen((playing) {
      if (mounted) state = state.copyWith(isPlaying: playing);
    }));

    _subs.add(_sharedPlayer.processingStateStream.listen((ps) {
      if (!mounted) return;
      final loading = ps == ProcessingState.loading || ps == ProcessingState.buffering;
      state = state.copyWith(isLoading: loading);
    }));

    _subs.add(_sharedPlayer.currentIndexStream.listen((index) {
      if (index != null && index < state.queue.length && mounted) {
        state = state.copyWith(
          currentTrack: state.queue[index],
          queueIndex: index,
        );
      }
    }));
  }

  Future<void> _handleTrackEnd() async {
    switch (state.repeatMode) {
      case PlayerRepeatMode.one:
        // On web, stream connection closes on completion — must re-fetch via setUrl()
        if (state.currentTrack != null) {
          await playTrack(state.currentTrack!, queue: state.queue, startIndex: state.queueIndex);
        }
        break;
      case PlayerRepeatMode.all:
        final nextIdx = _nextIndex();
        if (nextIdx != null) {
          await playTrack(state.queue[nextIdx], queue: state.queue, startIndex: nextIdx);
        } else if (state.queue.isNotEmpty) {
          await playTrack(state.queue[0], queue: state.queue, startIndex: 0);
        }
        break;
      case PlayerRepeatMode.none:
        final nextIdx = _nextIndex();
        if (nextIdx != null) {
          await playTrack(state.queue[nextIdx], queue: state.queue, startIndex: nextIdx);
        }
        // else: end of queue, stop — mini player stays visible (Spotify behavior)
        break;
    }
  }

  int? _nextIndex() {
    if (state.queue.isEmpty) return null;
    if (state.shuffleEnabled && state.shuffleOrder.isNotEmpty) {
      final pos = state.shuffleOrder.indexOf(state.queueIndex);
      final next = pos + 1;
      return next < state.shuffleOrder.length ? state.shuffleOrder[next] : null;
    }
    final next = state.queueIndex + 1;
    return next < state.queue.length ? next : null;
  }

  int? _prevIndex() {
    if (state.queue.isEmpty) return null;
    if (state.shuffleEnabled && state.shuffleOrder.isNotEmpty) {
      final pos = state.shuffleOrder.indexOf(state.queueIndex);
      final prev = pos - 1;
      return prev >= 0 ? state.shuffleOrder[prev] : null;
    }
    final prev = state.queueIndex - 1;
    return prev >= 0 ? prev : null;
  }

  List<int> _buildShuffleOrder(int queueLength, int currentIndex) {
    final indices = List<int>.generate(queueLength, (i) => i)..remove(currentIndex);
    indices.shuffle(Random());
    return [currentIndex, ...indices];
  }

  // ── Public API ────────────────────────────────────────────────────────────

  Future<void> playTrack(TrackModel track,
      {List<TrackModel>? queue, int? startIndex}) async {
    final newQueue = queue ?? [track];
    final idx = startIndex ?? newQueue.indexWhere((t) => t.id == track.id);
    final resolvedIdx = idx < 0 ? 0 : idx;

    debugPrint('[Player] playTrack: ${track.title} (index: $resolvedIdx, queue: ${newQueue.length})');

    final shuffleOrder = state.shuffleEnabled
        ? _buildShuffleOrder(newQueue.length, resolvedIdx)
        : <int>[];

    state = state.copyWith(
      currentTrack: track,
      queue: newQueue,
      queueIndex: resolvedIdx,
      isLoading: true,
      shuffleOrder: shuffleOrder,
      clearError: true,
      position: Duration.zero,
      duration: Duration.zero,
    );

    try {
      // Build a concatenating source so Android notifications show Prev/Next buttons
      final playlist = ConcatenatingAudioSource(
        useLazyPreparation: true,
        children: newQueue.map((t) => AudioSource.uri(
          Uri.parse('$_baseUrl/api/v1/tracks/${t.id}/stream'),
          tag: MediaItem(
            id: t.id.toString(),
            album: "SilverSync Library",
            title: t.title,
            artist: t.artist,
            artUri: Uri.parse(t.albumArtUrl),
          ),
        )).toList(),
      );

      // setAudioSource is enough, no need to call stop() first
      await _sharedPlayer.setAudioSource(
        playlist,
        initialIndex: resolvedIdx,
        initialPosition: Duration.zero,
      );
      
      await _sharedPlayer.play();
    } catch (e) {
      debugPrint('[Player] Error loading track: $e');
      if (mounted) {
        state = state.copyWith(
          isLoading: false,
          isPlaying: false,
          error: 'Cannot stream: ${track.title}',
        );
      }
    }
  }

  Future<void> togglePlayPause() async {
    if (_sharedPlayer.playing) {
      await _sharedPlayer.pause();
    } else {
      if (_sharedPlayer.processingState == ProcessingState.completed) {
        await _sharedPlayer.seek(Duration.zero);
      }
      await _sharedPlayer.play();
    }
  }

  Future<void> skipNext() async {
    debugPrint('[Player] skipNext (hasNext: ${_sharedPlayer.hasNext}, queue: ${state.queue.length})');
    if (_sharedPlayer.hasNext) {
      await _sharedPlayer.seekToNext();
    } else if (state.queue.length > 1) {
      // Only loop back to start if there's more than one track
      await _sharedPlayer.seek(Duration.zero, index: 0);
    } else {
      // If only one track, just reset to start
      await _sharedPlayer.seek(Duration.zero);
    }
  }

  Future<void> skipPrevious() async {
    debugPrint('[Player] skipPrevious (hasPrev: ${_sharedPlayer.hasPrevious}, pos: ${state.position.inSeconds}s)');
    // If we're more than 2 seconds into the song, just restart it (standard behavior)
    if (state.position.inSeconds > 2) {
      await _sharedPlayer.seek(Duration.zero);
      return;
    }
    
    if (_sharedPlayer.hasPrevious) {
      await _sharedPlayer.seekToPrevious();
    } else if (state.queue.length > 1) {
      // Loop back to the last song if at the beginning of the queue
      await _sharedPlayer.seek(Duration.zero, index: state.queue.length - 1);
    } else {
      // If only one track, just reset to start
      await _sharedPlayer.seek(Duration.zero);
    }
  }

  Future<void> seekTo(double progress) async {
    final dur = state.duration;
    if (dur.inMilliseconds == 0) return;
    final pos = Duration(milliseconds: (dur.inMilliseconds * progress).round());
    await _sharedPlayer.seek(pos);
  }

  void updateCurrentTrackFavorite(bool isFavorite) {
    if (state.currentTrack != null) {
      final updatedTrack = state.currentTrack!.copyWith(isFavorite: isFavorite);
      
      // Update queue as well so the next/prev doesn't revert the favorite status
      final updatedQueue = List<TrackModel>.from(state.queue);
      if (state.queueIndex >= 0 && state.queueIndex < updatedQueue.length) {
        updatedQueue[state.queueIndex] = updatedTrack;
      }

      state = state.copyWith(
        currentTrack: updatedTrack,
        queue: updatedQueue,
      );
    }
  }

  void cycleRepeatMode() {
    final modes = PlayerRepeatMode.values;
    final nextMode = modes[(state.repeatMode.index + 1) % modes.length];
    state = state.copyWith(repeatMode: nextMode);
    _savePreference('repeatMode', nextMode.index);

    // Sync with just_audio
    switch (nextMode) {
      case PlayerRepeatMode.none:
        _sharedPlayer.setLoopMode(LoopMode.off);
        break;
      case PlayerRepeatMode.one:
        _sharedPlayer.setLoopMode(LoopMode.one);
        break;
      case PlayerRepeatMode.all:
        _sharedPlayer.setLoopMode(LoopMode.all);
        break;
    }
  }

  void toggleShuffle() {
    final newShuffle = !state.shuffleEnabled;
    state = state.copyWith(shuffleEnabled: newShuffle);
    _savePreference('shuffleEnabled', newShuffle);
    
    _sharedPlayer.setShuffleModeEnabled(newShuffle);
  }

  /// Removes a track from the current active queue (e.g. if it was deleted from library)
  void removeTrackFromQueue(int trackId) {
    final oldQueue = state.queue;
    final indexInQueue = oldQueue.indexWhere((t) => t.id == trackId);
    
    if (indexInQueue == -1) return; // Not in current queue

    final newQueue = List<TrackModel>.from(oldQueue)..removeAt(indexInQueue);
    
    // If the removed track is the CURRENTLY PLAYING track, we should stop or skip.
    if (state.currentTrack?.id == trackId) {
      if (newQueue.isEmpty) {
        stop();
      } else {
        // Skip to next if possible, else just stop
        skipNext();
      }
      return;
    }

    // Otherwise, just update the queue and adjust index if the removed track was before current
    int newIndex = state.queueIndex;
    if (indexInQueue < state.queueIndex) {
      newIndex--;
    }

    // Rebuild shuffle order if needed
    List<int> newShuffleOrder = [];
    if (state.shuffleEnabled) {
      newShuffleOrder = _buildShuffleOrder(newQueue.length, newIndex);
    }

    state = state.copyWith(
      queue: newQueue,
      queueIndex: newIndex,
      shuffleOrder: newShuffleOrder,
    );
  }

  void stop() {
    _sharedPlayer.stop();
    state = const PlayerStateModel();
  }

  @override
  void dispose() {
    // Cancel subscriptions but DO NOT dispose the shared player
    // The player must stay alive across hot reloads and notifier rebuilds
    for (final sub in _subs) {
      sub.cancel();
    }
    _subs.clear();
    super.dispose();
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────
final audioPlayerProvider =
    StateNotifierProvider<AudioPlayerNotifier, PlayerStateModel>(
  (ref) => AudioPlayerNotifier(),
);
