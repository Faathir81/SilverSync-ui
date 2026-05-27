import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';

/// A small pill-shaped badge that displays a track count label.
/// Shows `'...'` during loading and `'OFFLINE'` on error.
class TrackCountBadge extends StatelessWidget {
  final String label;

  const TrackCountBadge({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryTeal.withOpacity(0.1),
        border: Border.all(color: AppColors.primaryTeal.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: AppTheme.monoStyle(
          fontSize: 9,
          color: AppColors.primaryTeal,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
