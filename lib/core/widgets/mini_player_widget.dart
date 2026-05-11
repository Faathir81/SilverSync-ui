import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/colors.dart';
import '../theme/app_theme.dart';
import '../services/audio_player_service.dart';
import 'cached_album_art.dart';
import 'marquee_text.dart';
import '../../features/player/presentation/pages/full_player_page.dart';

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
        color: AppColors.background.withOpacity(0.95), // Original Flat Style
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress line on top
            Container(
              height: 2,
              width: double.infinity,
              color: Colors.white.withOpacity(0.05),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: state.progress,
                child: Container(color: AppColors.primaryTeal),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Hero(
                  tag: 'albumArt_${state.currentTrack?.id ?? "none"}',
                  child: CachedAlbumArt(
                    url: state.currentTrack?.albumArtUrl,
                    size: 45,
                    borderRadius: 4,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MarqueeText(
                        text: state.currentTrack?.title ?? 'NO TRACK',
                        style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(fontSize: 14, color: Colors.white) ?? const TextStyle(fontSize: 14, color: Colors.white),
                      ),
                      Text(
                        state.currentTrack?.artist ?? 'SYSTEM IDLE',
                        style: AppTheme.monoStyle(fontSize: 10, color: AppColors.primaryTeal.withOpacity(0.5)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                _playerAction(
                  state.isPlaying ? Icons.pause : Icons.play_arrow,
                  player.togglePlayPause,
                ),
                const SizedBox(width: 10),
                _playerAction(
                  Icons.skip_next,
                  player.skipNext,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _playerAction(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.white10),
        ),
        child: Icon(icon, size: 20, color: Colors.white70),
      ),
    );
  }
}
