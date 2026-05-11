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
  final VoidCallback onRevoke;

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
    return GestureDetector(
      onTap: isLoading ? null : (isOnline ? onRefresh : onConnect),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isOnline
              ? accentColor.withOpacity(0.04)
              : AppColors.primaryTeal.withOpacity(0.04),
          border: Border.all(
            color: isOnline
                ? accentColor.withOpacity(0.2)
                : AppColors.primaryTeal.withOpacity(0.25),
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (isOnline ? accentColor : AppColors.primaryTeal).withOpacity(0.1),
                border: Border.all(color: (isOnline ? accentColor : AppColors.primaryTeal).withOpacity(0.3)),
              ),
              child: isLoading
                  ? const Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 1.5)))
                  : Icon(icon, color: isOnline ? accentColor : AppColors.primaryTeal, size: 20),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                    fontSize: 14,
                    color: AppColors.textMain,
                  )),
                  Text(
                    isOnline ? 'Connected — Tap to refresh' : 'Not connected — Tap to login',
                    style: AppTheme.monoStyle(fontSize: 9, color: isOnline ? accentColor.withOpacity(0.6) : AppColors.primaryTeal.withOpacity(0.5)),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: isLoading ? null : (isOnline ? onRevoke : onConnect),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isOnline ? Colors.redAccent.withOpacity(0.08) : AppColors.primaryTeal.withOpacity(0.1),
                  border: Border.all(color: isOnline ? Colors.redAccent.withOpacity(0.3) : AppColors.primaryTeal.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isOnline ? Icons.link_off : Icons.open_in_browser,
                      size: 12,
                      color: isOnline ? Colors.redAccent.withOpacity(0.8) : AppColors.primaryTeal,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isOnline ? 'REVOKE' : 'CONNECT',
                      style: AppTheme.monoStyle(
                        fontSize: 10,
                        color: isOnline ? Colors.redAccent.withOpacity(0.8) : AppColors.primaryTeal,
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
