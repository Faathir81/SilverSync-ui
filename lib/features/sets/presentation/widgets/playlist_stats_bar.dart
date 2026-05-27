import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';

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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(value: collectionsCount.toString(), label: 'Collections', color: AppColors.accent),
          Container(width: 1, height: 32, color: AppColors.surfaceBorder),
          _StatItem(value: totalTracks.toString(), label: 'Total Tracks', color: AppColors.accentWarm),
          Container(width: 1, height: 32, color: AppColors.surfaceBorder),
          _StatItem(value: libraryUsed, label: 'Library Size', color: AppColors.textPrimary),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _StatItem({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTheme.darkTheme.textTheme.displaySmall?.copyWith(
            fontSize: 22,
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
