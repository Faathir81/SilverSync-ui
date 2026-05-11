import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/angular_container.dart';
import '../../data/models/quota_model.dart';

class StorageQuotaCard extends StatelessWidget {
  final QuotaModel quota;

  const StorageQuotaCard({
    super.key,
    required this.quota,
  });

  @override
  Widget build(BuildContext context) {
    return AngularContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SYSTEM // STORAGE', style: AppTheme.monoStyle(fontSize: 10, color: AppColors.primaryTeal)),
                  Text('Google Drive Quota', style: AppTheme.darkTheme.textTheme.bodyLarge),
                ],
              ),
              _buildSmallBadge('LIVE'),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppColors.primaryTeal.withOpacity(0.3), blurRadius: 20, spreadRadius: 5),
                    BoxShadow(color: AppColors.primaryMagenta.withOpacity(0.1), blurRadius: 40, spreadRadius: -5),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        value: quota.usedPercentage / 100,
                        strokeWidth: 8,
                        backgroundColor: Colors.white.withOpacity(0.05),
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryTeal),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FittedBox(
                          child: Text(quota.usedShort, style: AppTheme.monoStyle(fontSize: 20, color: AppColors.primaryTeal, fontWeight: FontWeight.bold).copyWith(
                            shadows: [Shadow(color: AppColors.primaryTeal, blurRadius: 10)],
                          )),
                        ),
                        Text('OF ${quota.capacity}', style: AppTheme.monoStyle(fontSize: 8, color: AppColors.textMuted)),
                        const SizedBox(height: 2),
                        Text('${quota.usedPercentage.toStringAsFixed(1)}% USED', style: AppTheme.monoStyle(fontSize: 8, color: AppColors.primaryMagenta).copyWith(
                          shadows: [Shadow(color: AppColors.primaryMagenta, blurRadius: 8)],
                        )),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: [
                    _buildQuotaInfo('CAPACITY', quota.capacity, AppColors.primaryTeal),
                    const SizedBox(height: 10),
                    _buildQuotaInfo('LIBRARY SIZE', quota.silversyncUsed, AppColors.primaryMagenta),
                    const SizedBox(height: 10),
                    _buildQuotaInfo('FREE', quota.free, AppColors.primaryTeal),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Stack(
            children: [
              Container(height: 4, width: double.infinity, color: Colors.white10),
              LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    height: 4,
                    width: constraints.maxWidth * (quota.usedPercentage / 100),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [AppColors.primaryTeal, AppColors.primaryMagenta]),
                    ),
                  );
                }
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0 GB', style: AppTheme.monoStyle(fontSize: 8, color: AppColors.textMuted)),
              Text('${quota.usedPercentage.toStringAsFixed(1)}% ALLOCATED', style: AppTheme.monoStyle(fontSize: 8, color: AppColors.primaryTeal)),
              Text(quota.capacity, style: AppTheme.monoStyle(fontSize: 8, color: AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallBadge(String text) {
    return AngularContainer(
      cutSize: 4,
      width: 40,
      height: 20,
      child: Center(
        child: Text(text, style: AppTheme.monoStyle(fontSize: 8, color: AppColors.primaryTeal, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildQuotaInfo(String label, String value, Color color) {
    return AngularContainer(
      cutSize: 6,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTheme.monoStyle(fontSize: 8, color: color, letterSpacing: 1)),
            const SizedBox(height: 2),
            Text(value, style: AppTheme.monoStyle(fontSize: 14, color: color, fontWeight: FontWeight.bold).copyWith(
              shadows: [Shadow(color: color, blurRadius: 8)],
            )),
          ],
        ),
      ),
    );
  }
}
