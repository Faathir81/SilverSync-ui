import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/player/audio_player_provider.dart';

/// Displays "X OF Y" queue position info at the bottom of the full player.
/// Returns an empty widget when the queue is empty.
class QueueInfoWidget extends StatelessWidget {
  final PlayerStateModel state;

  const QueueInfoWidget({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.queue.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.queue_music_rounded,
          size: 12,
          color: AppColors.textMuted.withOpacity(0.35),
        ),
        const SizedBox(width: 6),
        Text(
          '${state.queueIndex + 1} OF ${state.queue.length}',
          style: AppTheme.monoStyle(
            fontSize: 10,
            color: AppColors.textMuted.withOpacity(0.35),
          ),
        ),
      ],
    );
  }
}
