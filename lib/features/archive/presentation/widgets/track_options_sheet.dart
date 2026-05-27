import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/player/audio_player_provider.dart';
import '../../../../core/providers/notification_provider.dart';
import '../providers/track_provider.dart';
import '../../data/models/track_model.dart';
import 'add_to_playlist_sheet.dart';
import 'edit_metadata_dialog.dart';

class TrackOptionsSheet extends ConsumerWidget {
  final TrackModel track;

  const TrackOptionsSheet({super.key, required this.track});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceHigh,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        padding: const EdgeInsets.only(top: 12, bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),

            // Track info header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          track.title,
                          style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          track.artist,
                          style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Divider(color: AppColors.surfaceBorder, height: 1),

            _OptionTile(
              icon: Icons.edit_rounded,
              iconColor: AppColors.accentWarm,
              label: 'Edit Metadata',
              onTap: () {
                Navigator.pop(context);
                showDialog(context: context, builder: (_) => EditMetadataDialog(track: track));
              },
            ),
            _OptionTile(
              icon: Icons.playlist_add_rounded,
              iconColor: AppColors.accent,
              label: 'Add to Collection',
              onTap: () {
                Navigator.pop(context);
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (_) => AddToPlaylistSheet(trackId: track.id),
                );
              },
            ),
            _OptionTile(
              icon: Icons.delete_outline_rounded,
              iconColor: const Color(0xFFFF6B6B),
              label: 'Delete from Library',
              isDestructive: true,
              onTap: () async {
                Navigator.pop(context);
                final api = ref.read(apiServiceProvider);
                await api.deleteTrack(track.id.toString());
                ref.read(audioPlayerProvider.notifier).removeTrackFromQueue(track.id);
                ref.read(notificationProvider.notifier).show('Track deleted');
                ref.invalidate(tracksProvider);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _OptionTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(
        label,
        style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
          fontSize: 15,
          color: isDestructive ? const Color(0xFFFF6B6B) : AppColors.textPrimary,
        ),
      ),
      onTap: onTap,
    );
  }
}
