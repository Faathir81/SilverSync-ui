import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/colors.dart';
import '../theme/app_theme.dart';
import '../player/audio_player_provider.dart';
import 'cached_album_art.dart';
import 'marquee_text.dart';
import '../../features/player/presentation/pages/full_player_page.dart';

class MiniPlayerWidget extends ConsumerWidget {
  const MiniPlayerWidget({super.key});

  void _openFullPlayer(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.transparent,
        transitionDuration: const Duration(milliseconds: 450),
        reverseTransitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const FullPlayerPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final slide = Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutQuart,
            reverseCurve: Curves.easeInQuart,
          ));
          return SlideTransition(position: slide, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasTrack = ref.watch(audioPlayerProvider.select((s) => s.hasTrack));
    if (!hasTrack) return const SizedBox.shrink();

    final state = ref.watch(audioPlayerProvider);
    final player = ref.read(audioPlayerProvider.notifier);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: GestureDetector(
        onTap: () => _openFullPlayer(context),
        onHorizontalDragEnd: (d) {
          if ((d.primaryVelocity ?? 0) > 300) player.skipPrevious();
          if ((d.primaryVelocity ?? 0) < -300) player.skipNext();
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceHigh.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.07),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Main Row ──────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 8, 8),
                    child: Row(
                      children: [
                        // Album art
                        Hero(
                          tag: 'albumArt_${state.currentTrack?.id ?? "none"}',
                          child: CachedAlbumArt(
                            url: state.currentTrack?.albumArtUrl,
                            size: 46,
                            borderRadius: 10,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Track info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              MarqueeText(
                                text: state.currentTrack?.title ?? '',
                                style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ) ?? const TextStyle(),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                state.currentTrack?.artist ?? '',
                                style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        // Controls
                        _Btn(
                          icon: Icons.skip_previous_rounded,
                          size: 22,
                          onTap: player.skipPrevious,
                        ),
                        _Btn(
                          icon: state.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          size: 28,
                          isAccent: true,
                          onTap: player.togglePlayPause,
                        ),
                        _Btn(
                          icon: Icons.skip_next_rounded,
                          size: 22,
                          onTap: player.skipNext,
                        ),
                        const SizedBox(width: 4),
                      ],
                    ),
                  ),

                  // ── Progress Bar ──────────────────────────────────────────
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(18),
                    ),
                    child: LinearProgressIndicator(
                      value: state.progress,
                      backgroundColor: Colors.white.withValues(alpha: 0.06),
                      valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                      minHeight: 2.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Btn extends StatefulWidget {
  final IconData icon;
  final double size;
  final bool isAccent;
  final VoidCallback onTap;

  const _Btn({
    required this.icon,
    required this.onTap,
    this.size = 22,
    this.isAccent = false,
  });

  @override
  State<_Btn> createState() => _BtnState();
}

class _BtnState extends State<_Btn> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.85 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: Icon(
            widget.icon,
            size: widget.size,
            color: widget.isAccent ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
