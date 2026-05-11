import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants/colors.dart';
import '../theme/app_theme.dart';

class SilverSyncNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const SilverSyncNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 8, left: 10, right: 10),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.95),
        border: Border(
          top: BorderSide(color: AppColors.primaryTeal.withOpacity(0.2), width: 1),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, -5)),
        ],
      ),
      child: SafeArea(
        top: false, // Disable top padding in SafeArea to reduce gap
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _navItem(0, Icons.home_rounded, 'HOME'),
            _navItem(1, FontAwesomeIcons.bolt, 'SYNC'),
            _navItem(2, Icons.library_music_rounded, 'ARCHIVE'),
            _navItem(3, Icons.playlist_play_rounded, 'SETS'),
            _navItem(4, Icons.settings_rounded, 'CONFIG'),
          ],
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    bool isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 65,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.only(bottom: isSelected ? 4 : 0, top: isSelected ? 0 : 4),
              child: Icon(
                icon,
                size: 24,
                color: isSelected ? AppColors.primaryTeal : AppColors.textMuted.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTheme.monoStyle(
                fontSize: 9,
                color: isSelected ? AppColors.textMain : AppColors.textMuted.withOpacity(0.6),
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 6),
            // Glowing Indicator Line
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              height: 2,
              width: isSelected ? 30 : 0,
              decoration: BoxDecoration(
                color: AppColors.primaryTeal,
                boxShadow: isSelected ? [
                  BoxShadow(color: AppColors.primaryTeal, blurRadius: 8, spreadRadius: 1),
                ] : [],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
