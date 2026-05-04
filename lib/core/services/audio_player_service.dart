import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../../../features/archive/data/models/track_model.dart';

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

  static const String _baseUrl = 'http://localhost:8080';

  AudioPlayerNotifier() : super(const PlayerStateModel()) {
    // Stop any zombie audio from a previous notifier (hot reload scenario).
    // This ensures clean state — no audio without a visible mini player.
    _sharedPlayer.stop();
    _subscribeToPlayer();
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
      if (ps == ProcessingState.completed) {
        _handleTrackEnd();
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
      final streamUrl = '$_baseUrl/api/v1/tracks/${track.id}/stream';
      // stop() then setUrl() ensures no overlap when switching tracks quickly
      await _sharedPlayer.stop();
      await _sharedPlayer.setUrl(streamUrl);
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
    final nextIdx = _nextIndex();
    if (nextIdx != null) {
      await playTrack(state.queue[nextIdx], queue: state.queue, startIndex: nextIdx);
    } else if (state.repeatMode == PlayerRepeatMode.all && state.queue.isNotEmpty) {
      await playTrack(state.queue[0], queue: state.queue, startIndex: 0);
    }
  }

  Future<void> skipPrevious() async {
    if (state.position.inSeconds > 3) {
      await _sharedPlayer.seek(Duration.zero);
      return;
    }
    final prevIdx = _prevIndex();
    if (prevIdx != null) {
      await playTrack(state.queue[prevIdx], queue: state.queue, startIndex: prevIdx);
    }
  }

  Future<void> seekTo(double progress) async {
    final ms = (state.duration.inMilliseconds * progress).toInt();
    await _sharedPlayer.seek(Duration(milliseconds: ms));
  }

  void cycleRepeatMode() {
    final modes = PlayerRepeatMode.values;
    final nextMode = modes[(state.repeatMode.index + 1) % modes.length];
    state = state.copyWith(repeatMode: nextMode);
  }

  void toggleShuffle() {
    final newShuffle = !state.shuffleEnabled;
    final shuffleOrder = newShuffle && state.queue.isNotEmpty
        ? _buildShuffleOrder(state.queue.length, state.queueIndex)
        : <int>[];
    state = state.copyWith(shuffleEnabled: newShuffle, shuffleOrder: shuffleOrder);
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
