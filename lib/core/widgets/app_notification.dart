import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/colors.dart';
import '../theme/app_theme.dart';
import '../providers/notification_provider.dart';

class AppNotification extends ConsumerWidget {
  final double bottomOffset;

  const AppNotification({super.key, this.bottomOffset = 0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notification = ref.watch(notificationProvider);
    final color = notification.isError ? AppColors.primaryMagenta : AppColors.primaryTeal;
    final label = notification.isError ? 'SYSTEM ERROR' : 'SYSTEM NOTIFICATION';
    final icon = notification.isError ? Icons.warning_amber_rounded : Icons.bolt_rounded;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      bottom: notification.isVisible ? bottomOffset + 20 : bottomOffset - 120,
      left: 20,
      right: 20,
      child: IgnorePointer(
        ignoring: !notification.isVisible,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: notification.isVisible ? 1.0 : 0.0,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.background.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.15),
                  blurRadius: 20,
                  spreadRadius: -2,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: AppTheme.monoStyle(fontSize: 8, color: color.withValues(alpha: 0.5), letterSpacing: 1),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        notification.message,
                        style: AppTheme.monoStyle(fontSize: 12, color: AppColors.textMain, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
