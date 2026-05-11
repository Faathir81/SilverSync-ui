import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/angular_container.dart';

class AuthNodeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isOnline;
  final VoidCallback? onTap;

  const AuthNodeCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isOnline,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AngularContainer(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isOnline 
                    ? AppColors.primaryTeal.withOpacity(0.3) 
                    : Colors.white10
                ),
              ),
              child: Icon(
                icon, 
                color: isOnline ? AppColors.primaryTeal : AppColors.textMuted, 
                size: 20
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(fontSize: 14)),
                  Text(
                    subtitle, 
                    style: AppTheme.monoStyle(
                      fontSize: 9, 
                      color: isOnline ? AppColors.primaryTeal.withOpacity(0.7) : AppColors.textMuted
                    )
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isOnline 
                  ? AppColors.primaryTeal.withOpacity(0.1) 
                  : Colors.redAccent.withOpacity(0.05),
                border: Border.all(
                  color: isOnline 
                    ? AppColors.primaryTeal.withOpacity(0.3) 
                    : Colors.redAccent.withOpacity(0.2)
                ),
              ),
              child: Text(
                isOnline ? 'ONLINE' : 'OFFLINE',
                style: AppTheme.monoStyle(
                  fontSize: 8, 
                  color: isOnline ? AppColors.primaryTeal : Colors.redAccent,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
