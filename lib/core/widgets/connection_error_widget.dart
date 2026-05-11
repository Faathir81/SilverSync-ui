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
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.05),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.redAccent.withOpacity(0.2)),
              ),
              child: const Icon(Icons.wifi_off_rounded, color: Colors.redAccent, size: 40),
            ),
            const SizedBox(height: 24),
            Text(
              'GATEWAY_CONNECTION_FAILED',
              style: AppTheme.monoStyle(
                fontSize: 14,
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Could not establish a secure link to the SilverSync engine. Please check your network bridge.',
              style: AppTheme.monoStyle(
                fontSize: 10,
                color: AppColors.textMuted.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  border: Border.all(color: AppColors.primaryTeal.withOpacity(0.4)),
                  boxShadow: [
                    BoxShadow(color: AppColors.primaryTeal.withOpacity(0.1), blurRadius: 10),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.refresh_rounded, color: AppColors.primaryTeal, size: 16),
                    const SizedBox(width: 10),
                    Text(
                      'RETRY_CONNECTION',
                      style: AppTheme.monoStyle(
                        fontSize: 11,
                        color: AppColors.primaryTeal,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
