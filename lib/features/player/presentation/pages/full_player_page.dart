import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/player/audio_player_provider.dart';
import '../../../../core/widgets/ambient_background.dart';
import '../widgets/player_controls.dart';
import '../widgets/player_seek_bar.dart';
import '../widgets/player_album_art.dart';
import '../widgets/queue_info_widget.dart';

class FullPlayerPage extends ConsumerStatefulWidget {
  const FullPlayerPage({super.key});

  @override
  ConsumerState<FullPlayerPage> createState() => _FullPlayerPageState();
}

class _FullPlayerPageState extends ConsumerState<FullPlayerPage>
    with SingleTickerProviderStateMixin {
  // Drag-to-dismiss state
  double _dragOffset = 0.0;
  bool _isDragging = false;

  // Threshold to auto-dismiss when dragged this far down
  static const double _dismissThreshold = 200.0;

  void _onDragUpdate(DragUpdateDetails details) {
    if (details.delta.dy > 0 || _dragOffset > 0) {
      setState(() {
        _dragOffset = (_dragOffset + details.delta.dy).clamp(0.0, double.infinity);
        _isDragging = true;
      });
    }
  }

  void _onDragEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond.dy;
    // Dismiss if dragged past threshold OR flung down fast
    if (_dragOffset > _dismissThreshold || velocity > 800) {
      Navigator.of(context).pop();
    } else {
      // Spring back
      setState(() {
        _dragOffset = 0.0;
        _isDragging = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(audioPlayerProvider);
    final player = ref.read(audioPlayerProvider.notifier);

    if (state.currentTrack == null) {
      return const Scaffold(body: Center(child: Text('NO TRACK SELECTED')));
    }

    final track = state.currentTrack!;

    // Opacity fades as we drag down
    final dragProgress = (_dragOffset / _dismissThreshold).clamp(0.0, 1.0);
    final opacity = (1.0 - dragProgress * 0.4).clamp(0.0, 1.0);
    final scale = (1.0 - dragProgress * 0.05).clamp(0.0, 1.0);

    return GestureDetector(
      onVerticalDragUpdate: _onDragUpdate,
      onVerticalDragEnd: _onDragEnd,
      child: AnimatedContainer(
        duration: _isDragging ? Duration.zero : const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _dragOffset, 0),
        child: Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Stack(
                children: [
                  const AmbientBackground(),

                  SafeArea(
                    child: Column(
                      children: [
                        // ── Drag Handle + Top Bar ──
                        GestureDetector(
                          onVerticalDragUpdate: _onDragUpdate,
                          onVerticalDragEnd: _onDragEnd,
                          child: Column(
                            children: [
                              // Drag handle (like Spotify's pill)
                              Padding(
                                padding: const EdgeInsets.only(top: 12, bottom: 4),
                                child: Container(
                                  width: 36,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.white24,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: Colors.white70,
                                        size: 30,
                                      ),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          'PLAYING FROM',
                                          style: AppTheme.monoStyle(
                                            fontSize: 9,
                                            color: AppColors.textMuted,
                                          ),
                                        ),
                                        Text(
                                          'SILVERSYNC LIBRARY',
                                          style: AppTheme.monoStyle(
                                            fontSize: 11,
                                            color: AppColors.primaryTeal,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.more_horiz_rounded,
                                        color: Colors.white70,
                                      ),
                                      onPressed: () {},
                                    ),
                                  ],
                                ),
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
                                style: AppTheme.darkTheme.textTheme.displayLarge
                                    ?.copyWith(fontSize: 24),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                track.artist.toUpperCase(),
                                style: AppTheme.monoStyle(
                                  fontSize: 12,
                                  color: AppColors.primaryTeal,
                                  letterSpacing: 2,
                                ),
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
                        QueueInfoWidget(state: state),

                        const SizedBox(height: 30),
                      ],
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
