import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/audio_player_service.dart';
import '../../../../core/widgets/ambient_background.dart';
import '../widgets/player_controls.dart';
import '../widgets/player_seek_bar.dart';
import '../widgets/player_album_art.dart';

class FullPlayerPage extends ConsumerWidget {
  const FullPlayerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(audioPlayerProvider);
    final player = ref.read(audioPlayerProvider.notifier);

    if (state.currentTrack == null) {
      return const Scaffold(body: Center(child: Text('NO TRACK SELECTED')));
    }

    final track = state.currentTrack!;

    return Scaffold(
      body: Stack(
        children: [
          const AmbientBackground(),
          
          SafeArea(
            child: Column(
              children: [
                // ── Top Bar ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70, size: 30),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Column(
                        children: [
                          Text('PLAYING FROM', style: AppTheme.monoStyle(fontSize: 9, color: AppColors.textMuted)),
                          Text('SILVERSYNC LIBRARY', style: AppTheme.monoStyle(fontSize: 11, color: AppColors.primaryTeal, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_horiz_rounded, color: Colors.white70),
                        onPressed: () {}, // Future: Track Options
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // ── Album Art ──
                PlayerAlbumArt(track: track, isPlaying: state.isPlaying),

                const Spacer(),

                // ── Track Info ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      Text(
                        track.title,
                        style: AppTheme.darkTheme.textTheme.displayLarge?.copyWith(fontSize: 24),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        track.artist.toUpperCase(),
                        style: AppTheme.monoStyle(fontSize: 12, color: AppColors.primaryTeal, letterSpacing: 2),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // ── Seek Bar ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: PlayerSeekBar(state: state, player: player),
                ),

                const SizedBox(height: 40),

                // ── Controls ──
                PlayerControls(state: state, player: player),

                const SizedBox(height: 40),

                // ── Queue Info ──
                _buildQueueInfo(state),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueInfo(PlayerStateModel state) {
    if (state.queue.isEmpty) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.queue_music_rounded, size: 12, color: AppColors.textMuted.withOpacity(0.35)),
        const SizedBox(width: 6),
        Text(
          '${state.queueIndex + 1} OF ${state.queue.length}',
          style: AppTheme.monoStyle(fontSize: 10, color: AppColors.textMuted.withOpacity(0.35)),
        ),
      ],
    );
  }
}
