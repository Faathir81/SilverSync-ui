import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/archive/data/models/track_model.dart';
import '../constants/app_constants.dart';
import 'player_state.dart';

// ─── AudioPlayerNotifier ──────────────────────────────────────────────────────
// Manages all audio playback logic and exposes a clean public API.
//
// DESIGN NOTES:
// - Uses a NON-static AudioPlayer instance created fresh in the constructor.
// - The provider is declared with [keepAlive: true] so Riverpod NEVER disposes
//   this notifier (and thus never disposes the player) as long as the app runs.
// - This avoids the old "static AudioPlayer created before JustAudioBackground
//   init" bug while still keeping the player alive across page navigations.
class AudioPlayerNotifier extends StateNotifier<PlayerStateModel> {
  /// The player instance. Non-static — ownership is clear and lifecycle is
  /// controlled entirely by this notifier (which is kept alive by the provider).
  final AudioPlayer _player = AudioPlayer();

  /// Active stream subscriptions — cancelled on dispose.
  final List<StreamSubscription> _subs = [];

  static const String _baseUrl = AppConstants.baseUrl;

  AudioPlayerNotifier() : super(const PlayerStateModel()) {
    _loadPreferences();
    _subscribeToPlayer();
  }

  // ── Initialisation ─────────────────────────────────────────────────────────

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
    if (value is int) await prefs.setInt(key, value);
    if (value is bool) await prefs.setBool(key, value);
  }

  void _subscribeToPlayer() {
    // Sync initial state in case of app restart while background service is running
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        state = state.copyWith(
          position: _player.position,
          duration: _player.duration ?? Duration.zero,
          isPlaying: _player.playing,
        );
      }
    });

    _subs.add(_player.positionStream.listen((pos) {
      if (mounted) state = state.copyWith(position: pos);
    }));

    _subs.add(_player.durationStream.listen((dur) {
      if (dur != null && mounted) state = state.copyWith(duration: dur);
    }));

    _subs.add(_player.playingStream.listen((playing) {
      if (mounted) state = state.copyWith(isPlaying: playing);
    }));

    _subs.add(_player.processingStateStream.listen((ps) {
      if (!mounted) return;
      final loading =
          ps == ProcessingState.loading || ps == ProcessingState.buffering;
      state = state.copyWith(isLoading: loading);

      // Auto-advance to next track when current one finishes
      if (ps == ProcessingState.completed) {
        _handleTrackCompletion();
      }
    }));

    _subs.add(_player.currentIndexStream.listen((index) {
      if (index != null && index < state.queue.length && mounted) {
        state = state.copyWith(
          currentTrack: state.queue[index],
          queueIndex: index,
        );
      }
    }));

    // Listen to sequence state to reconstruct queue if app restarts
    _subs.add(_player.sequenceStateStream.listen((sequenceState) {
      if (sequenceState == null || !mounted) return;
      final sequence = sequenceState.sequence;
      if (sequence.isNotEmpty && state.queue.isEmpty) {
        final newQueue = sequence.map((source) {
          final tag = source.tag as MediaItem;
          return TrackModel(
            id: int.tryParse(tag.id) ?? 0,
            title: tag.title,
            artist: tag.artist ?? '',
            albumArtUrl: tag.artUri?.toString() ?? '',
            isFavorite: false,
            spotifyId: '',
            driveFileId: '',
            quality: 'high',
            createdAt: DateTime.now(),
          );
        }).toList();
        
        final idx = sequenceState.currentIndex;
        state = state.copyWith(
          queue: newQueue,
          queueIndex: idx,
          currentTrack: (idx < newQueue.length) ? newQueue[idx] : null,
        );
      }
    }));
  }

  /// Called when the player reaches the end of the playlist.
  void _handleTrackCompletion() {
    switch (state.repeatMode) {
      case PlayerRepeatMode.one:
        _player.seek(Duration.zero);
        _player.play();
        break;
      case PlayerRepeatMode.all:
        if (state.queue.isNotEmpty) {
          _player.seek(Duration.zero, index: 0);
          _player.play();
        }
        break;
      case PlayerRepeatMode.none:
        // Stay paused at the end
        break;
    }
  }

  // ── Public API ────────────────────────────────────────────────────────────

  /// Plays [track], optionally loading a full [queue] starting at [startIndex].
  /// Always builds a [ConcatenatingAudioSource] so Android media notifications
  /// expose Prev/Next buttons.
  Future<void> playTrack(
    TrackModel track, {
    List<TrackModel>? queue,
    int? startIndex,
  }) async {
    final newQueue = queue ?? [track];
    final idx = startIndex ?? newQueue.indexWhere((t) => t.id == track.id);
    final resolvedIdx = idx < 0 ? 0 : idx;

    debugPrint('[Player] playTrack: "${track.title}" '
        '(index=$resolvedIdx, queueLen=${newQueue.length})');

    // Update UI state immediately so the player shows the selected track
    state = state.copyWith(
      currentTrack: track,
      queue: newQueue,
      queueIndex: resolvedIdx,
      isLoading: true,
      clearError: true,
      position: Duration.zero,
      duration: Duration.zero,
    );

    try {
      final playlist = ConcatenatingAudioSource(
        useLazyPreparation: true,
        children: newQueue
            .map(
              (t) => LockCachingAudioSource(
                Uri.parse('$_baseUrl/api/v1/tracks/${t.id}/stream'),
                tag: MediaItem(
                  id: t.id.toString(),
                  album: 'SilverSync Library',
                  title: t.title,
                  artist: t.artist,
                  artUri: Uri.tryParse(t.albumArtUrl),
                ),
              ),
            )
            .toList(),
      );

      await _player.setAudioSource(
        playlist,
        initialIndex: resolvedIdx,
        initialPosition: Duration.zero,
      );
      debugPrint('[Player] AudioSource set. Calling play()...');
      await _player.play();
      debugPrint('[Player] play() called successfully.');
    } catch (e, st) {
      debugPrint('[Player] ❌ Error in playTrack: $e\n$st');
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
    debugPrint('[Player] togglePlayPause — currently playing: ${_player.playing}');
    if (_player.playing) {
      await _player.pause();
    } else {
      if (_player.processingState == ProcessingState.completed) {
        await _player.seek(Duration.zero);
      }
      await _player.play();
    }
  }

  Future<void> skipNext() async {
    debugPrint('[Player] skipNext '
        '(hasNext=${_player.hasNext}, queue=${state.queue.length})');
    if (_player.hasNext) {
      await _player.seekToNext();
    } else if (state.queue.length > 1) {
      await _player.seek(Duration.zero, index: 0);
    } else {
      await _player.seek(Duration.zero);
    }
  }

  Future<void> skipPrevious() async {
    // Standard behavior: if > 2s into song, restart it; otherwise go to prev
    if (state.position.inSeconds > 2) {
      await _player.seek(Duration.zero);
      return;
    }
    if (_player.hasPrevious) {
      await _player.seekToPrevious();
    } else if (state.queue.length > 1) {
      await _player.seek(Duration.zero, index: state.queue.length - 1);
    } else {
      await _player.seek(Duration.zero);
    }
  }

  /// Seeks to an absolute [progress] value in [0.0, 1.0].
  Future<void> seekTo(double progress) async {
    final dur = state.duration;
    if (dur.inMilliseconds == 0) return;
    final pos = Duration(milliseconds: (dur.inMilliseconds * progress).round());
    await _player.seek(pos);
  }

  /// Optimistically updates the favorite state of the current track in the queue.
  void updateCurrentTrackFavorite(bool isFavorite) {
    if (state.currentTrack == null) return;
    final updatedTrack = state.currentTrack!.copyWith(isFavorite: isFavorite);
    final updatedQueue = List<TrackModel>.from(state.queue);
    if (state.queueIndex >= 0 && state.queueIndex < updatedQueue.length) {
      updatedQueue[state.queueIndex] = updatedTrack;
    }
    state = state.copyWith(currentTrack: updatedTrack, queue: updatedQueue);
  }

  /// Cycles through [PlayerRepeatMode] values and syncs with just_audio.
  void cycleRepeatMode() {
    final modes = PlayerRepeatMode.values;
    final nextMode = modes[(state.repeatMode.index + 1) % modes.length];
    state = state.copyWith(repeatMode: nextMode);
    _savePreference('repeatMode', nextMode.index);

    switch (nextMode) {
      case PlayerRepeatMode.none:
        _player.setLoopMode(LoopMode.off);
        break;
      case PlayerRepeatMode.one:
        _player.setLoopMode(LoopMode.one);
        break;
      case PlayerRepeatMode.all:
        _player.setLoopMode(LoopMode.all);
        break;
    }
  }

  void toggleShuffle() {
    final newShuffle = !state.shuffleEnabled;
    state = state.copyWith(shuffleEnabled: newShuffle);
    _savePreference('shuffleEnabled', newShuffle);
    _player.setShuffleModeEnabled(newShuffle);
  }

  /// Removes a track from the active queue (e.g. after deletion from library).
  void removeTrackFromQueue(int trackId) {
    final oldQueue = state.queue;
    final indexInQueue = oldQueue.indexWhere((t) => t.id == trackId);
    if (indexInQueue == -1) return;

    final newQueue = List<TrackModel>.from(oldQueue)..removeAt(indexInQueue);

    if (state.currentTrack?.id == trackId) {
      newQueue.isEmpty ? stop() : skipNext();
      return;
    }

    int newIndex = state.queueIndex;
    if (indexInQueue < state.queueIndex) newIndex--;

    state = state.copyWith(queue: newQueue, queueIndex: newIndex);
  }

  void stop() {
    _player.stop();
    state = const PlayerStateModel();
  }

  @override
  void dispose() {
    // The provider uses keepAlive:true so this should NEVER be called during
    // normal app use. If it is called, clean up properly.
    debugPrint('[Player] ⚠️ AudioPlayerNotifier disposed — this is unexpected.');
    for (final sub in _subs) {
      sub.cancel();
    }
    _subs.clear();
    _player.dispose();
    super.dispose();
  }
}
