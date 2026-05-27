import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';

/// A search bar styled for the SilverSync Archive page.
/// Calls [onChanged] whenever the search text changes.
/// Calls [onClear] when the clear (×) button is pressed.
class ArchiveSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final String query;

  const ArchiveSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(fontSize: 15),
        decoration: InputDecoration(
          hintText: 'Search Library...',
          hintStyle: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textMuted.withValues(alpha: 0.6),
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 20,
            color: AppColors.textMuted.withValues(alpha: 0.8),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          suffixIcon: query.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close_rounded, size: 18, color: AppColors.textMuted),
                  onPressed: onClear,
                )
              : null,
        ),
      ),
    );
  }
}
