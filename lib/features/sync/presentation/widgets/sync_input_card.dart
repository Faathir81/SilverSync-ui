import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';

class SyncInputCard extends StatelessWidget {
  final TextEditingController urlController;
  final bool isSubmitting;
  final VoidCallback onSync;

  const SyncInputCard({
    super.key,
    required this.urlController,
    required this.isSubmitting,
    required this.onSync,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF1DB954).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(FontAwesomeIcons.spotify, color: Color(0xFF1DB954), size: 18),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sync to Drive', style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(fontSize: 16)),
                  Text('Track or playlist URL', style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // URL Input
          TextField(
            controller: urlController,
            style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'https://open.spotify.com/track/...',
              hintStyle: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textTertiary,
                fontSize: 13,
              ),
              prefixIcon: const Icon(Icons.link_rounded, color: AppColors.textTertiary, size: 18),
              filled: true,
              fillColor: AppColors.surfaceHigh,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.accent),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Sync Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isSubmitting ? null : onSync,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.accent.withValues(alpha: 0.4),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: isSubmitting
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
                        ),
                        const SizedBox(width: 10),
                        Text('Syncing...', style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(color: Colors.white)),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.sync_rounded, size: 18),
                        const SizedBox(width: 8),
                        Text('Start Sync', style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(color: Colors.white)),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
