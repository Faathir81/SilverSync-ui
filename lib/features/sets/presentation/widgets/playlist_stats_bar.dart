import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/angular_container.dart';

class PlaylistStatsBar extends StatelessWidget {
  final int collectionsCount;
  final int totalTracks;
  final String libraryUsed;

  const PlaylistStatsBar({
    super.key,
    required this.collectionsCount,
    required this.totalTracks,
    required this.libraryUsed,
  });

  @override
  Widget build(BuildContext context) {
    return AngularContainer(
      cutSize: 8,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(collectionsCount.toString(), 'COLLECTIONS', AppColors.primaryTeal),
          Container(width: 1, height: 32, color: AppColors.primaryTeal.withOpacity(0.15)),
          _buildStatItem(totalTracks.toString(), 'TOTAL TRACKS', AppColors.primaryMagenta),
          Container(width: 1, height: 32, color: AppColors.primaryTeal.withOpacity(0.15)),
          _buildStatItem(libraryUsed, 'LIBRARY', AppColors.textMain),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color valueColor) {
    return Column(
      children: [
        Text(
          value, 
          style: AppTheme.monoStyle(fontSize: 18, color: valueColor).copyWith(
            shadows: [Shadow(color: valueColor.withOpacity(0.6), blurRadius: 5)]
          )
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTheme.monoStyle(fontSize: 10, color: AppColors.textMuted.withOpacity(0.5))),
      ],
    );
  }
}
