import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../theme/app_theme.dart';

class ConnectionErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ConnectionErrorWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B6B).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.wifi_off_rounded, color: Color(0xFFFF6B6B), size: 32),
            ),
            const SizedBox(height: 20),
            Text(
              'No connection',
              style: AppTheme.darkTheme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Could not reach the SilverSync server.\nCheck your network and try again.',
              style: AppTheme.darkTheme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Retry', style: TextStyle(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
