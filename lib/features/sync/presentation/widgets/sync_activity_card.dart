import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/sync_log_model.dart';

class SyncActivityCard extends StatelessWidget {
  final SyncLogModel job;
  final VoidCallback onDismiss;

  const SyncActivityCard({
    super.key,
    required this.job,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final (color, icon, label) = _statusProps();

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
          // Header Row
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      job.spotifyUrl,
                      style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 18),
                color: AppColors.textTertiary,
                onPressed: onDismiss,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Progress indicator if active
          if (!job.isDone && !job.isFailed) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                minHeight: 4,
                backgroundColor: AppColors.surfaceHigh,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Message log
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              job.message.isEmpty ? 'Waiting for response...' : job.message,
              style: AppTheme.monoStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  (Color, IconData, String) _statusProps() {
    if (job.isDone) return (AppColors.accentGreen, Icons.check_circle_rounded, 'Completed');
    if (job.isFailed) return (const Color(0xFFFF6B6B), Icons.error_rounded, 'Failed');
    if (job.status == 'processing' || job.status == 'downloading' || job.status == 'uploading') {
      return (AppColors.accent, Icons.sync_rounded, job.status[0].toUpperCase() + job.status.substring(1));
    }
    return (AppColors.textSecondary, Icons.hourglass_empty_rounded, 'Pending');
  }
}
