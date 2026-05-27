import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/api_service.dart';
import '../../../sets/presentation/providers/playlist_provider.dart';

class AddToPlaylistSheet extends ConsumerWidget {
  final int trackId;

  const AddToPlaylistSheet({super.key, required this.trackId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistsAsync = ref.watch(playlistsProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Add to Collection', style: AppTheme.darkTheme.textTheme.displaySmall?.copyWith(fontSize: 18)),
          const SizedBox(height: 20),
          playlistsAsync.when(
            data: (playlists) {
              if (playlists.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text('No collections yet', style: AppTheme.darkTheme.textTheme.bodyMedium),
                  ),
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: playlists.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final pl = playlists[index];
                  return GestureDetector(
                    onTap: () {
                      addTrackToPlaylist(ref.read(apiServiceProvider), ref, pl.id, trackId);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.queue_music_rounded, color: AppColors.accent, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(pl.name, style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(fontSize: 15)),
                                Text('${pl.tracks.length} tracks', style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(fontSize: 12)),
                              ],
                            ),
                          ),
                          const Icon(Icons.add_rounded, color: AppColors.textSecondary, size: 20),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(AppColors.accent)),
              ),
            ),
            error: (_, __) => Center(
              child: Text('Could not load collections', style: AppTheme.darkTheme.textTheme.bodyMedium),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
