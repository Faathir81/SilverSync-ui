import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/audio_player_service.dart';
import '../../../../core/providers/notification_provider.dart';
import '../providers/track_provider.dart';
import '../../data/models/track_model.dart';
import 'add_to_playlist_sheet.dart';
import 'edit_metadata_dialog.dart';

class TrackOptionsSheet extends ConsumerWidget {
  final TrackModel track;

  const TrackOptionsSheet({
    super.key,
    required this.track,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textMuted.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.edit, color: AppColors.primaryMagenta),
            title: Text('Edit Metadata', style: AppTheme.monoStyle(fontSize: 14, color: AppColors.primaryMagenta)),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => EditMetadataDialog(track: track),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.playlist_add, color: AppColors.primaryTeal),
            title: Text('Add to Collection', style: AppTheme.monoStyle(fontSize: 14, color: AppColors.textMain)),
            onTap: () {
              Navigator.pop(context);
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (context) => AddToPlaylistSheet(trackId: track.id),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
            title: Text('Delete from Library', style: AppTheme.monoStyle(fontSize: 14, color: Colors.redAccent)),
            onTap: () async {
              Navigator.pop(context);
              final api = ref.read(apiServiceProvider);
              await api.deleteTrack(track.id.toString());
              
              ref.read(audioPlayerProvider.notifier).removeTrackFromQueue(track.id);
              ref.read(notificationProvider.notifier).show('TRACK PERMANENTLY DELETED');
              ref.invalidate(tracksProvider);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
