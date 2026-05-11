import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/angular_container.dart';

class SystemStatusCard extends StatelessWidget {
  final bool isApiOnline;

  const SystemStatusCard({
    super.key,
    required this.isApiOnline,
  });

  @override
  Widget build(BuildContext context) {
    return AngularContainer(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          _buildStatusRow('SYNC_ENGINE', isApiOnline ? 'STANDBY' : 'OFFLINE', isApiOnline ? AppColors.primaryTeal : Colors.redAccent),
          const SizedBox(height: 8),
          _buildStatusRow('API_GATEWAY', isApiOnline ? 'NOMINAL' : 'UNREACHABLE', isApiOnline ? AppColors.primaryTeal : Colors.redAccent),
          const SizedBox(height: 8),
          _buildStatusRow('AUTH_SERVICE', isApiOnline ? 'ACTIVE' : 'OFFLINE', isApiOnline ? AppColors.primaryTeal : Colors.redAccent),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String status, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTheme.monoStyle(fontSize: 10, color: color)),
        Row(
          children: [
            Icon(Icons.play_arrow, size: 12, color: color),
            const SizedBox(width: 4),
            SizedBox(
              width: 75,
              child: Text(
                status, 
                style: AppTheme.monoStyle(
                  fontSize: 10, 
                  color: color, 
                  fontWeight: FontWeight.bold
                )
              ),
            ),
          ],
        ),
      ],
    );
  }
}
