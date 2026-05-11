import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/angular_container.dart';

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
    return AngularContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('INGEST // SPOTIFY ENDPOINT',
              style: AppTheme.monoStyle(fontSize: 10, color: AppColors.primaryTeal)),
          const SizedBox(height: 4),
          Text('Sync to Drive', style: AppTheme.darkTheme.textTheme.bodyLarge),
          const SizedBox(height: 5),
          Text('Supports track & playlist URLs',
              style: AppTheme.monoStyle(fontSize: 10, color: AppColors.textMuted.withOpacity(0.6))),
          const SizedBox(height: 20),
          _buildUrlInput(),
          const SizedBox(height: 15),
          _buildSyncButton(),
        ],
      ),
    );
  }

  Widget _buildUrlInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        border: Border.all(color: AppColors.primaryTeal.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: TextField(
        controller: urlController,
        style: AppTheme.monoStyle(color: AppColors.primaryTeal),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'open.spotify.com/track/... or /playlist/...',
          hintStyle: AppTheme.monoStyle(color: AppColors.primaryTeal.withOpacity(0.3)),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Text('URL://',
                style: AppTheme.monoStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.bold)),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        ),
      ),
    );
  }

  Widget _buildSyncButton() {
    return GestureDetector(
      onTap: isSubmitting ? null : onSync,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isSubmitting ? 0.5 : 1.0,
        child: AngularContainer(
          cutSize: 8,
          isActive: !isSubmitting,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isSubmitting) ...[
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryTeal),
                  ),
                ),
                const SizedBox(width: 10),
                Text('QUEUING...',
                    style: AppTheme.monoStyle(
                        fontSize: 14,
                        color: AppColors.primaryTeal,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2)),
              ] else ...[
                const Icon(FontAwesomeIcons.bolt, size: 16, color: AppColors.primaryTeal),
                const SizedBox(width: 10),
                Text('INITIATE SYNC',
                    style: AppTheme.monoStyle(
                        fontSize: 14,
                        color: AppColors.primaryTeal,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2)),
                const SizedBox(width: 10),
                const Icon(Icons.send_rounded, size: 16, color: AppColors.primaryTeal),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
