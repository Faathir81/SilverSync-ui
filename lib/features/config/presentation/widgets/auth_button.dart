import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';

class AuthButton extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color accentColor;
  final bool isOnline;
  final bool isLoading;
  final VoidCallback onConnect;
  final VoidCallback onRefresh;
  final Future<void> Function() onRevoke;

  const AuthButton({
    super.key,
    required this.name,
    required this.icon,
    required this.accentColor,
    required this.isOnline,
    required this.isLoading,
    required this.onConnect,
    required this.onRefresh,
    required this.onRevoke,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          // Service icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: isLoading
                ? Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(accentColor),
                      ),
                    ),
                  )
                : Icon(icon, color: accentColor, size: 22),
          ),
          const SizedBox(width: 14),

          // Name + status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(fontSize: 15)),
                const SizedBox(height: 2),
                Text(
                  isOnline ? 'Connected' : 'Not connected',
                  style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    color: isOnline ? AppColors.accentGreen : AppColors.textTertiary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Action button
          GestureDetector(
            onTap: isLoading ? null : (isOnline ? onRevoke : onConnect),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: isOnline
                    ? const Color(0xFFFF6B6B).withValues(alpha: 0.1)
                    : AppColors.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isOnline
                      ? const Color(0xFFFF6B6B).withValues(alpha: 0.3)
                      : AppColors.accent.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                isOnline ? 'Revoke' : 'Connect',
                style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                  color: isOnline ? const Color(0xFFFF6B6B) : AppColors.accent,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
