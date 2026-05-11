import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/api_service.dart';
import '../../../sets/presentation/providers/playlist_provider.dart';

class AddToPlaylistSheet extends ConsumerWidget {
  final int trackId;

  const AddToPlaylistSheet({
    super.key,
    required this.trackId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistsAsync = ref.watch(playlistsProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: AppColors.primaryTeal.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMuted.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'ADD TO COLLECTION',
            style: AppTheme.monoStyle(fontSize: 14, color: AppColors.primaryTeal, letterSpacing: 2),
          ),
          const SizedBox(height: 20),
          playlistsAsync.when(
            data: (playlists) {
              if (playlists.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text('NO COLLECTIONS FOUND',
                        style: AppTheme.monoStyle(fontSize: 12, color: AppColors.textMuted)),
                  ),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: playlists.length,
                itemBuilder: (context, index) {
                  final pl = playlists[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.primaryTeal.withOpacity(0.1)),
                      ),
                      child: const Icon(Icons.playlist_play_rounded, color: AppColors.primaryTeal, size: 20),
                    ),
                    title: Text(pl.name, style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(fontSize: 15)),
                    subtitle: Text('${pl.tracks.length} tracks',
                        style: AppTheme.monoStyle(fontSize: 10, color: AppColors.textMuted)),
                    onTap: () {
                      final api = ref.read(apiServiceProvider);
                      addTrackToPlaylist(api, ref, pl.id, trackId);
                      Navigator.pop(context);
                    },
                  );
                },
              );
            },
            loading: () => const Center(
                child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            )),
            error: (err, _) => Center(
              child: Text('CONNECTION ERROR', style: AppTheme.monoStyle(color: Colors.redAccent)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
