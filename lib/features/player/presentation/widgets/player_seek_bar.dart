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
            child: SizedBox(
              height: 30,
              width: double.infinity,
              child: Stack(
                clipBehavior: Clip.none, // Prevent thumb from being cut off at edges
                alignment: Alignment.centerLeft,
                children: [
                  // Background Track
                  Container(
                    height: 4,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Progress Fill
                  Container(
                    height: 4,
                    width: width * state.progress,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryTeal, AppColors.primaryMagenta],
                      ),
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryTeal.withOpacity(0.4),
                          blurRadius: 8,
                        ),
                      ],
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
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(state.positionStr,
                style: AppTheme.monoStyle(fontSize: 11, color: AppColors.textMuted.withOpacity(0.5))),
            Text(state.durationStr,
                style: AppTheme.monoStyle(fontSize: 11, color: AppColors.textMuted.withOpacity(0.5))),
          ],
        ),
      ],
    );
  }
}
