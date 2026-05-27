import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/player/audio_player_provider.dart';

class PlayerSeekBar extends StatelessWidget {
  final PlayerStateModel state;
  final AudioPlayerNotifier player;

  const PlayerSeekBar({
    super.key,
    required this.state,
    required this.player,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LayoutBuilder(builder: (context, constraints) {
          final width = constraints.maxWidth;
          return GestureDetector(
            onHorizontalDragUpdate: (details) {
              final box = context.findRenderObject() as RenderBox;
              final localPos = box.globalToLocal(details.globalPosition);
              final pct = (localPos.dx / width).clamp(0.0, 1.0);
              player.seekTo(pct);
            },
            onTapDown: (details) {
              final box = context.findRenderObject() as RenderBox;
              final localPos = box.globalToLocal(details.globalPosition);
              final pct = (localPos.dx / width).clamp(0.0, 1.0);
              player.seekTo(pct);
            },
            child: SizedBox(
              height: 30,
              width: double.infinity,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.centerLeft,
                children: [
                  // Background Track
                  Container(
                    height: 5,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  // Progress Fill
                  Container(
                    height: 5,
                    width: width * state.progress,
                    decoration: BoxDecoration(
                      color: AppColors.textMain,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  // Handle
                  Positioned(
                    left: (width * state.progress) - 8,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.textMain,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
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
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              state.positionStr,
              style: AppTheme.monoStyle(
                fontSize: 12,
                color: AppColors.textMuted.withValues(alpha: 0.8),
              ),
            ),
            Text(
              state.durationStr,
              style: AppTheme.monoStyle(
                fontSize: 12,
                color: AppColors.textMuted.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
