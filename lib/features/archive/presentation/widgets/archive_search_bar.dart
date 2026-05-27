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
      height: 45,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        border: Border.all(color: AppColors.primaryTeal.withOpacity(0.15)),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppTheme.monoStyle(fontSize: 13, color: AppColors.textMain),
        decoration: InputDecoration(
          hintText: 'SEARCH_DATABASE...',
          hintStyle: AppTheme.monoStyle(
            fontSize: 12,
            color: AppColors.textMuted.withOpacity(0.3),
          ),
          prefixIcon: Icon(
            Icons.search,
            size: 18,
            color: AppColors.primaryTeal.withOpacity(0.4),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          suffixIcon: query.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: onClear,
                )
              : null,
        ),
      ),
    );
  }
}
