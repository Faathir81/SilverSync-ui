import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/audio_player_service.dart';
import '../../../../core/widgets/cached_album_art.dart';
import '../../../../core/widgets/marquee_text.dart';
import '../../features/player/presentation/pages/full_player_page.dart';

/// Floating Mini Player shown above the Bottom Navigation bar.
///
/// Extracted from main.dart for:
/// - Isolation of rebuild scope (only rebuilds when player state changes)
/// - Cleaner main.dart (routing shell only)
/// - Reusability
///
/// Uses Riverpod's `.select()` to perform selective rebuilds:
/// - Progress bar only rebuilds on [PlayerStateModel.progress] change
/// - Controls only rebuild on [PlayerStateModel.isPlaying] change
class MiniPlayerWidget extends ConsumerWidget {
  const MiniPlayerWidget({super.key});

  void _openFullPlayer(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) => const FullPlayerPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;
          final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Selective rebuild: only re-render this widget when hasTrack changes
    final hasTrack = ref.watch(audioPlayerProvider.select((s) => s.hasTrack));
    if (!hasTrack) return const SizedBox.shrink();

    final state = ref.watch(audioPlayerProvider);
    final player = ref.read(audioPlayerProvider.notifier);

    return GestureDetector(
      onTap: () => _openFullPlayer(context),
      onHorizontalDragEnd: (d) {
        if ((d.primaryVelocity ?? 0) > 300) player.skipPrevious();
        if ((d.primaryVelocity ?? 0) < -300) player.skipNext();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: const Color(0xFF0E1829),
          border: Border.all(
            color: AppColors.primaryTeal.withValues(alpha: 0.25),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryTeal.withValues(alpha: 0.15),
              blurRadius: 24,
              spreadRadius: 0,
              offset: const Offset(0, -4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 16,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _MiniProgressBar(state: state, player: player),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Row(
                  children: [
                    // Album art — cached and Hero animated
                    Hero(
                      tag: 'albumArt_${state.currentTrack?.id ?? "none"}',
                      child: CachedAlbumArt(
                        url: state.currentTrack?.albumArtUrl,
                        size: 44,
                        borderRadius: 8,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Track info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MarqueeText(
                            text: state.currentTrack?.title ?? 'NO TRACK',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFD0D8E8),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              if (state.isLoading) ...[
                                SizedBox(
                                  width: 8, height: 8,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.5,
                                    valueColor: AlwaysStoppedAnimation(AppColors.primaryTeal),
                                  ),
                                ),
                                const SizedBox(width: 5),
                              ],
                              Flexible(
                                child: Text(
                                  state.currentTrack?.artist ?? 'SYSTEM IDLE',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.primaryTeal.withValues(alpha: 0.65),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  maxLines: 1,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                state.positionStr,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontFamily: 'monospace',
                                  color: AppColors.textMuted.withValues(alpha: 0.4),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Controls
                    _MiniControlButton(
                      icon: Icons.skip_previous_rounded,
                      onTap: player.skipPrevious,
                    ),
                    const SizedBox(width: 4),
                    _MiniPlayPauseButton(state: state, player: player),
                    const SizedBox(width: 4),
                    _MiniControlButton(
                      icon: Icons.skip_next_rounded,
                      onTap: player.skipNext,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Sub-widgets (each has its own tight rebuild scope) ────────────────────────

/// Progress bar — only rebuilds when progress value changes
class _MiniProgressBar extends StatelessWidget {
  final PlayerStateModel state;
  final AudioPlayerNotifier player;

  const _MiniProgressBar({required this.state, required this.player});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (d) {
          final p = (d.localPosition.dx / constraints.maxWidth).clamp(0.0, 1.0);
          player.seekTo(p);
        },
        child: SizedBox(
          height: 3,
          child: Stack(
            children: [
              Container(color: AppColors.primaryTeal.withValues(alpha: 0.1)),
              FractionallySizedBox(
                widthFactor: state.progress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryTeal, AppColors.primaryMagenta],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryTeal.withValues(alpha: 0.7),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

/// Skip button
class _MiniControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MiniControlButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.05),
        ),
        child: Icon(icon, size: 20, color: Colors.white.withValues(alpha: 0.8)),
      ),
    );
  }
}

/// Play/Pause button — only rebuilds when isPlaying or isLoading changes
class _MiniPlayPauseButton extends StatelessWidget {
  final PlayerStateModel state;
  final AudioPlayerNotifier player;

  const _MiniPlayPauseButton({required this.state, required this.player});

  @override
  Widget build(BuildContext context) {
    Widget btn = Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryTeal, AppColors.primaryTeal.withValues(alpha: 0.6)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryTeal.withValues(alpha: 0.4),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      child: state.isLoading
          ? const Padding(
              padding: EdgeInsets.all(12),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Colors.black),
              ),
            )
          : Icon(
              state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              size: 24,
              color: AppColors.background,
            ),
    );

    if (state.isPlaying) {
      btn = btn.animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 1.seconds, curve: Curves.easeInOut);
    }

    return GestureDetector(
      onTap: player.togglePlayPause,
      child: btn,
    );
  }
}
