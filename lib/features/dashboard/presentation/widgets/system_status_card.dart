import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';

class SystemStatusCard extends StatelessWidget {
  final bool isApiOnline;

  const SystemStatusCard({super.key, required this.isApiOnline});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        children: [
          _Row('Sync Engine', isApiOnline ? 'Standby' : 'Offline', isApiOnline),
          const SizedBox(height: 10),
          Divider(color: AppColors.surfaceBorder, height: 1),
          const SizedBox(height: 10),
          _Row('API Gateway', isApiOnline ? 'Operational' : 'Unreachable', isApiOnline),
          const SizedBox(height: 10),
          Divider(color: AppColors.surfaceBorder, height: 1),
          const SizedBox(height: 10),
          _Row('Auth Service', isApiOnline ? 'Active' : 'Offline', isApiOnline),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String status;
  final bool isGood;
  const _Row(this.label, this.status, this.isGood);

  @override
  Widget build(BuildContext context) {
    final color = isGood ? AppColors.accentGreen : const Color(0xFFFF6B6B);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(fontSize: 15)),
        Row(
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                boxShadow: [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 6)],
              ),
            ),
            const SizedBox(width: 6),
            Text(
              status,
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
