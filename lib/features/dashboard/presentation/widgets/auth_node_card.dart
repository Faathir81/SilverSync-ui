import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';

class AuthNodeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isOnline;
  final VoidCallback? onTap;

  const AuthNodeCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isOnline,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isOnline
                    ? AppColors.accentGreen.withValues(alpha: 0.12)
                    : AppColors.surfaceHigh,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isOnline ? AppColors.accentGreen : AppColors.textTertiary,
                size: 18,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(fontSize: 15)),
                  Text(
                    subtitle,
                    style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isOnline
                    ? AppColors.accentGreen.withValues(alpha: 0.12)
                    : Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isOnline ? AppColors.accentGreen : AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    isOnline ? 'Online' : 'Offline',
                    style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                      color: isOnline ? AppColors.accentGreen : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
