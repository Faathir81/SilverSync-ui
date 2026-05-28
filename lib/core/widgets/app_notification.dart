import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/colors.dart';
import '../theme/app_theme.dart';
import '../providers/notification_provider.dart';

class AppNotification extends ConsumerStatefulWidget {
  final double bottomOffset;

  const AppNotification({super.key, this.bottomOffset = 0});

  @override
  ConsumerState<AppNotification> createState() => _AppNotificationState();
}

class _AppNotificationState extends ConsumerState<AppNotification> {
  double _horizontalOffset = 0.0;
  bool _isDismissingHorizontally = false;

  @override
  Widget build(BuildContext context) {
    final notification = ref.watch(notificationProvider);
    final color = notification.isError ? AppColors.primaryMagenta : AppColors.primaryTeal;
    final label = notification.isError ? 'SYSTEM ERROR' : 'SYSTEM NOTIFICATION';
    final icon = notification.isError ? Icons.warning_amber_rounded : Icons.bolt_rounded;

    // Reset offset when hidden from other sources
    if (!notification.isVisible && !_isDismissingHorizontally && _horizontalOffset != 0) {
      _horizontalOffset = 0.0;
    }

    final isVisible = notification.isVisible || _isDismissingHorizontally;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      top: isVisible ? 60 : -120,
      left: 20,
      right: 20,
      child: IgnorePointer(
        ignoring: !isVisible,
        child: GestureDetector(
          onHorizontalDragUpdate: (details) {
            if (_isDismissingHorizontally) return;
            setState(() {
              _horizontalOffset += details.primaryDelta!;
            });
          },
          onHorizontalDragEnd: (details) {
            if (_isDismissingHorizontally) return;
            // Lowered thresholds for a very responsive, light-flick feel
            if (_horizontalOffset.abs() > 30 || details.primaryVelocity!.abs() > 100) {
              // Animate off screen horizontally
              setState(() {
                _isDismissingHorizontally = true;
                _horizontalOffset = _horizontalOffset > 0 ? 500 : -500;
              });
              
              // Wait for horizontal animation to finish, then hide globally
              Future.delayed(const Duration(milliseconds: 300), () {
                if (mounted) {
                  ref.read(notificationProvider.notifier).hide();
                  setState(() {
                    _isDismissingHorizontally = false;
                    _horizontalOffset = 0.0;
                  });
                }
              });
            } else {
              // Bounce back
              setState(() {
                _horizontalOffset = 0.0;
              });
            }
          },
          child: AnimatedContainer(
            duration: (_horizontalOffset == 0 || _isDismissingHorizontally) 
                ? const Duration(milliseconds: 300) 
                : Duration.zero,
            curve: Curves.easeOut,
            transform: Matrix4.translationValues(_horizontalOffset, 0, 0),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: isVisible ? 1.0 : 0.0,
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
        ),
      ),
    );
  }
}
