import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/quota_model.dart';

class StorageQuotaCard extends StatelessWidget {
  final QuotaModel quota;

  const StorageQuotaCard({super.key, required this.quota});

  @override
  Widget build(BuildContext context) {
    final pct = (quota.usedPercentage / 100).clamp(0.0, 1.0);
    final isNearFull = quota.usedPercentage > 75;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.cloud_rounded, color: AppColors.accent, size: 20),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Google Drive', style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(fontSize: 15)),
                  Text('Storage Quota', style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(fontSize: 12)),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    quota.usedShort,
                    style: AppTheme.darkTheme.textTheme.displaySmall?.copyWith(fontSize: 18),
                  ),
                  Text(
                    'of ${quota.capacity}',
                    style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.06),
              valueColor: AlwaysStoppedAnimation(
                isNearFull ? AppColors.accentWarm : AppColors.accent,
              ),
            ),
          ),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${quota.usedPercentage.toStringAsFixed(1)}% used',
                style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                  color: isNearFull ? AppColors.accentWarm : AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${quota.free} free',
                style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),

          if (quota.silversyncUsed.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.library_music_rounded, size: 16, color: AppColors.accent),
                  const SizedBox(width: 8),
                  Text('SilverSync Library', style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(fontSize: 13)),
                  const Spacer(),
                  Text(
                    quota.silversyncUsed,
                    style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
