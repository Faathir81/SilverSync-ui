import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/audio_player_service.dart';
import '../../../../core/widgets/cached_album_art.dart';
import '../../../../core/widgets/marquee_text.dart';

class FullPlayerPage extends ConsumerWidget {
  const FullPlayerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(audioPlayerProvider);
    final player = ref.read(audioPlayerProvider.notifier);
    final track = state.currentTrack;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Ambient glow
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.4,
                  colors: [
                    AppColors.primaryTeal.withOpacity(0.07),
                    AppColors.background,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50, right: -50,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppColors.primaryMagenta.withOpacity(0.06), Colors.transparent],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── Top Bar ──────────────────────────────────
                _buildTopBar(context, state, player),

                const SizedBox(height: 24),

                // ── Album Art ────────────────────────────────
                _buildAlbumArt(track),

                const SizedBox(height: 28),

                // ── Track Info + Shuffle/Repeat ───────────────
                _buildTrackInfo(state, player, track),

                const SizedBox(height: 24),

                // ── Seek Bar ─────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: _buildSeekBar(state, player),
                ),

                const SizedBox(height: 28),

                // ── Playback Controls ────────────────────────
                _buildControls(state, player),

                const SizedBox(height: 20),

                // ── Queue Info ───────────────────────────────
                _buildQueueInfo(state),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Top Bar ─────────────────────────────────────────────────────────────────
  Widget _buildTopBar(BuildContext context, PlayerStateModel state, AudioPlayerNotifier player) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Row(
        children: [
          _iconBtn(
            Icons.keyboard_arrow_down_rounded,
            size: 28,
            onTap: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'NOW PLAYING',
                  style: AppTheme.monoStyle(
                      fontSize: 9,
                      color: AppColors.primaryTeal.withOpacity(0.5),
                      letterSpacing: 3),
                ),
                const SizedBox(height: 2),
                Text(
                  state.currentTrack?.artist.toUpperCase() ?? '—',
                  style: AppTheme.monoStyle(
                      fontSize: 11,
                      color: AppColors.textMuted.withOpacity(0.7)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          _iconBtn(
            state.currentTrack?.isFavorite == true
                ? Icons.favorite
                : Icons.favorite_border,
            color: state.currentTrack?.isFavorite == true
                ? AppColors.primaryMagenta
                : AppColors.textMuted.withOpacity(0.4),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  // ── Album Art ────────────────────────────────────────────────────────────────
  Widget _buildAlbumArt(track) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryTeal.withValues(alpha: 0.22),
                blurRadius: 50,
                spreadRadius: 8,
              ),
              BoxShadow(
                color: AppColors.primaryMagenta.withValues(alpha: 0.07),
                blurRadius: 70,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Hero(
            tag: 'albumArt_${track?.id ?? "none"}',
            child: CachedAlbumArt(
              url: track?.albumArtUrl,
              size: double.infinity,
              borderRadius: 6,
              showGlow: false, // glow handled by parent BoxDecoration
            ),
          ),
        ),
      ),
    );
  }

  // ── Track Info + Shuffle/Repeat buttons ──────────────────────────────────────
  Widget _buildTrackInfo(PlayerStateModel state, AudioPlayerNotifier player, track) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Row(
        children: [
          // Shuffle button
          _modeButton(
            icon: Icons.shuffle_rounded,
            isActive: state.shuffleEnabled,
            onTap: () => player.toggleShuffle(),
          ),

          const SizedBox(width: 12),

          // Title + artist
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                MarqueeText(
                  text: track?.title ?? 'No Track Selected',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFD0D8E8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  track?.artist ?? '—',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted.withOpacity(0.6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Repeat button
          _modeButton(
            icon: state.repeatMode == PlayerRepeatMode.one
                ? Icons.repeat_one_rounded
                : Icons.repeat_rounded,
            isActive: state.repeatMode != PlayerRepeatMode.none,
            onTap: () => player.cycleRepeatMode(),
          ),
        ],
      ),
    );
  }

  // ── Seek Bar ─────────────────────────────────────────────────────────────────
  Widget _buildSeekBar(PlayerStateModel state, AudioPlayerNotifier player) {
    return Column(
      children: [
        // Seek track
        LayoutBuilder(builder: (ctx, constraints) {
          final progress = state.progress;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (d) {
              final p = (d.localPosition.dx / constraints.maxWidth).clamp(0.0, 1.0);
              player.seekTo(p);
            },
            onHorizontalDragUpdate: (d) {
              final p = (d.localPosition.dx / constraints.maxWidth).clamp(0.0, 1.0);
              player.seekTo(p);
            },
            child: SizedBox(
              height: 28,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background track
                  Container(
                    height: 4,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.primaryTeal.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Filled portion
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: progress,
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primaryTeal, AppColors.primaryMagenta],
                          ),
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryTeal.withOpacity(0.6),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Draggable thumb — positioned using Stack with left offset
                  Positioned(
                    left: (progress * (constraints.maxWidth - 16)).clamp(0.0, double.infinity),
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryTeal.withOpacity(0.9),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),

        const SizedBox(height: 6),

        // Time labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(state.positionStr,
                style: AppTheme.monoStyle(
                    fontSize: 11, color: AppColors.textMuted.withOpacity(0.5))),
            Text(state.durationStr,
                style: AppTheme.monoStyle(
                    fontSize: 11, color: AppColors.textMuted.withOpacity(0.5))),
          ],
        ),
      ],
    );
  }

  // ── Playback Controls ────────────────────────────────────────────────────────
  Widget _buildControls(PlayerStateModel state, AudioPlayerNotifier player) {
    Widget playBtn = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: state.isPlaying
              ? [AppColors.primaryTeal, const Color(0xFF00B8CC)]
              : [AppColors.primaryTeal.withValues(alpha: 0.8), AppColors.primaryTeal.withValues(alpha: 0.5)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryTeal.withValues(alpha: state.isPlaying ? 0.55 : 0.25),
            blurRadius: state.isPlaying ? 28 : 16,
            spreadRadius: state.isPlaying ? 4 : 1,
          ),
        ],
      ),
      child: state.isLoading
          ? const Padding(
              padding: EdgeInsets.all(22),
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation(Colors.black),
              ),
            )
          : Icon(
              state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              size: 38,
              color: AppColors.background,
            ),
    );

    if (state.isPlaying) {
      playBtn = playBtn.animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 1.2.seconds, curve: Curves.easeInOut);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Skip Previous
        _controlBtn(
          icon: Icons.skip_previous_rounded,
          size: 30,
          onTap: () => player.skipPrevious(),
        ),

        const SizedBox(width: 20),

        // Play / Pause — large glowing circle
        GestureDetector(
          onTap: () => player.togglePlayPause(),
          child: playBtn,
        ),

        const SizedBox(width: 20),

        // Skip Next
        _controlBtn(
          icon: Icons.skip_next_rounded,
          size: 30,
          onTap: () => player.skipNext(),
        ),
      ],
    );
  }

  // ── Queue Info ───────────────────────────────────────────────────────────────
  Widget _buildQueueInfo(PlayerStateModel state) {
    if (state.queue.isEmpty) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.queue_music_rounded, size: 12, color: AppColors.textMuted.withOpacity(0.35)),
        const SizedBox(width: 6),
        Text(
          '${state.queueIndex + 1} of ${state.queue.length}',
          style: AppTheme.monoStyle(fontSize: 10, color: AppColors.textMuted.withOpacity(0.35)),
        ),
        if (state.shuffleEnabled) ...[
          const SizedBox(width: 8),
          Text('• SHUFFLE',
              style: AppTheme.monoStyle(fontSize: 10, color: AppColors.primaryTeal.withOpacity(0.5))),
        ],
        if (state.repeatMode != PlayerRepeatMode.none) ...[
          const SizedBox(width: 8),
          Text(
            '• ${state.repeatMode == PlayerRepeatMode.one ? 'REPEAT 1' : 'REPEAT ALL'}',
            style: AppTheme.monoStyle(fontSize: 10, color: AppColors.primaryMagenta.withOpacity(0.6)),
          ),
        ],
      ],
    );
  }


  Widget _controlBtn({required IconData icon, required double size, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primaryTeal.withOpacity(0.07),
          border: Border.all(color: AppColors.primaryTeal.withOpacity(0.18)),
        ),
        child: Icon(icon, size: size, color: Colors.white.withOpacity(0.85)),
      ),
    );
  }

  Widget _modeButton({required IconData icon, required bool isActive, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? AppColors.primaryTeal.withOpacity(0.15) : Colors.transparent,
          border: Border.all(
            color: isActive ? AppColors.primaryTeal.withOpacity(0.5) : AppColors.textMuted.withOpacity(0.2),
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isActive ? AppColors.primaryTeal : AppColors.textMuted.withOpacity(0.4),
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon, {required VoidCallback onTap, Color? color, double size = 22}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        child: Icon(icon,
            size: size,
            color: color ?? AppColors.textMuted.withOpacity(0.55)),
      ),
    );
  }
}
