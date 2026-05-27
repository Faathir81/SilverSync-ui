// ─── Player State Types ───────────────────────────────────────────────────────
// Contains the PlayerRepeatMode enum and PlayerStateModel immutable data class.
// Kept separate from the notifier so the model can be imported without
// pulling in just_audio or other heavy dependencies.

import '../../../features/archive/data/models/track_model.dart';

/// Repeat mode for the audio player.
/// Named [PlayerRepeatMode] to avoid conflict with Flutter's built-in RepeatMode.
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

  /// Normalized playback progress in [0.0, 1.0].
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
