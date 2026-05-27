import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';

/// Badge showing track count — minimal pill style matching new design.
class TrackCountBadge extends StatelessWidget {
  final String label;
  const TrackCountBadge({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Text(
        label,
        style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
