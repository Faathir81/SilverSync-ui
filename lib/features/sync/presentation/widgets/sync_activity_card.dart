import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/angular_container.dart';

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
    Color statusColor;
    IconData statusIcon;
    String statusLabel;

    if (job.isDone) {
      statusColor = AppColors.primaryGreen;
      statusIcon = Icons.check_circle_outline;
      statusLabel = 'DONE';
    } else if (job.isFailed) {
      statusColor = Colors.redAccent;
      statusIcon = Icons.error_outline;
      statusLabel = 'FAILED';
    } else if (job.status == 'processing' || job.status == 'downloading' || job.status == 'uploading') {
      statusColor = AppColors.primaryTeal;
      statusIcon = Icons.sync;
      statusLabel = job.status.toUpperCase();
    } else {
      statusColor = AppColors.textMuted;
      statusIcon = Icons.hourglass_empty;
      statusLabel = 'PENDING';
    }

    return AngularContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('ACTIVE_TASK // MONITOR',
                  style: AppTheme.monoStyle(fontSize: 10, color: statusColor.withOpacity(0.7))),
              GestureDetector(
                onTap: onDismiss,
                child: Icon(Icons.close, size: 14, color: AppColors.textMuted.withOpacity(0.5)),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.05),
                  border: Border.all(color: statusColor.withOpacity(0.2)),
                ),
                child: Icon(statusIcon, color: statusColor, size: 20),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(job.spotifyUrl,
                        style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(statusLabel,
                        style: AppTheme.monoStyle(
                            fontSize: 10, color: statusColor, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildProgressSection(statusColor),
          const SizedBox(height: 15),
          _buildLogSection(),
        ],
      ),
    );
  }

  Widget _buildProgressSection(Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('STATUS', style: AppTheme.monoStyle(fontSize: 9, color: AppColors.textMuted)),
            Text(job.status,
                style: AppTheme.monoStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildLogSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('LAST_RESPONSE_LOG:',
              style: AppTheme.monoStyle(fontSize: 8, color: AppColors.textMuted.withOpacity(0.5))),
          const SizedBox(height: 4),
          Text(job.message.isEmpty ? 'Waiting for engine response...' : job.message,
              style: AppTheme.monoStyle(fontSize: 9, color: AppColors.textMuted.withOpacity(0.8))),
        ],
      ),
    );
  }
}
