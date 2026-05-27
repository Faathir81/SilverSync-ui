// ─── Audio Player — Barrel Export ─────────────────────────────────────────────
// Single import point for all player-related types.
// Usage: import 'package:silversync_ui/core/player/audio_player_provider.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'player_state.dart';
export 'audio_player_notifier.dart';

import 'audio_player_notifier.dart';
import 'player_state.dart';

/// The global audio player provider.
///
/// IMPORTANT: [keepAlive: true] ensures Riverpod NEVER disposes this notifier,
/// so the AudioPlayer instance stays alive for the entire app session.
/// This replaces the old "static AudioPlayer" pattern with a safer approach:
/// the player is created AFTER JustAudioBackground.init() completes (since
/// Riverpod providers are lazy — they're only initialized on first access).
final audioPlayerProvider =
    StateNotifierProvider.autoDispose<AudioPlayerNotifier, PlayerStateModel>(
  (ref) {
    // keepAlive prevents disposal when no widgets are watching.
    // Without this, navigating away from the player page would stop audio.
    ref.keepAlive();
    return AudioPlayerNotifier();
  },
);
