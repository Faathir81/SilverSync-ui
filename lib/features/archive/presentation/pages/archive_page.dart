import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/player/audio_player_provider.dart';
import '../../../../core/widgets/connection_error_widget.dart';
import '../../../../core/widgets/smart_marquee.dart';
import '../providers/track_provider.dart';
import '../widgets/archive_search_bar.dart';
import '../widgets/track_count_badge.dart';
import '../widgets/track_list_item.dart';
import '../widgets/track_options_sheet.dart';

class ArchivePage extends ConsumerStatefulWidget {
  const ArchivePage({super.key});

  @override
  ConsumerState<ArchivePage> createState() => _ArchivePageState();
}

class _ArchivePageState extends ConsumerState<ArchivePage> {
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) => setState(() => _searchQuery = value);

  void _onSearchCleared() {
    _searchController.clear();
    setState(() => _searchQuery = '');
  }

  void _showOptions(track) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => TrackOptionsSheet(track: track),
    );
  }

  Widget _buildMarquee({
    required String text,
    required TextStyle style,
    double height = 20,
    bool isPlaying = false,
  }) {
    return SmartMarquee(
      text: text,
      style: style,
      height: height,
      isActive: isPlaying,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tracksAsync = ref.watch(tracksProvider);
    final playerState = ref.watch(audioPlayerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ═══════════════ STICKY HEADER ═══════════════
        _ArchiveHeader(
          tracksAsync: tracksAsync,
          searchController: _searchController,
          searchQuery: _searchQuery,
          onSearchChanged: _onSearchChanged,
          onSearchCleared: _onSearchCleared,
        ),
        Container(height: 1, color: AppColors.primaryTeal.withOpacity(0.15)),

        // ═══════════════ SCROLLABLE TRACK LIST ═══════════════
        Expanded(
          child: tracksAsync.when(
            data: (tracks) {
              final filtered = tracks
                  .where((t) =>
                      t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      t.artist.toLowerCase().contains(_searchQuery.toLowerCase()))
                  .toList();

              if (filtered.isEmpty) {
                return Center(
                  child: Text(
                    _searchQuery.isEmpty ? 'NO TRACKS IN ARCHIVE' : 'NO RECORDS FOUND',
                    style: AppTheme.monoStyle(
                      fontSize: 12,
                      color: AppColors.primaryTeal.withOpacity(0.3),
                      letterSpacing: 2,
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 15, 16, 180),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final track = filtered[index];
                  final isPlaying = playerState.currentTrack?.id == track.id;

                  return TrackListItem(
                    track: track,
                    isPlaying: isPlaying,
                    onTap: () => ref
                        .read(audioPlayerProvider.notifier)
                        .playTrack(track, queue: filtered, startIndex: index),
                    onLongPress: () => _showOptions(track),
                    buildMarquee: _buildMarquee,
                  ).animate().fade(duration: 400.ms).slideX(
                        begin: 0.05,
                        curve: Curves.easeOutQuad,
                      );
                },
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryTeal),
              ),
            ),
            error: (err, _) => ConnectionErrorWidget(
              message: err.toString(),
              onRetry: () => ref.invalidate(tracksProvider),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Archive Header ───────────────────────────────────────────────────────────
/// The sticky header section of the Archive page — extracted for readability.
class _ArchiveHeader extends StatelessWidget {
  final AsyncValue tracksAsync;
  final TextEditingController searchController;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchCleared;

  const _ArchiveHeader({
    required this.tracksAsync,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onSearchCleared,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SYS // ACTIVE',
            style: AppTheme.monoStyle(
              fontSize: 12,
              color: AppColors.primaryTeal.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'SILVERSYNC',
            style: AppTheme.darkTheme.textTheme.displayLarge?.copyWith(
              shadows: const [Shadow(color: AppColors.primaryTeal, blurRadius: 10)],
            ),
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ARCHIVE // SYNCED TRACKS',
                    style: AppTheme.monoStyle(
                      fontSize: 10,
                      color: AppColors.primaryTeal.withOpacity(0.4),
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Library',
                    style: AppTheme.darkTheme.textTheme.bodyLarge
                        ?.copyWith(fontSize: 18),
                  ),
                ],
              ),
              tracksAsync.when(
                data: (tracks) => TrackCountBadge(label: '${tracks.length} FILES'),
                loading: () => const TrackCountBadge(label: '...'),
                error: (_, __) => const TrackCountBadge(label: 'OFFLINE'),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ArchiveSearchBar(
            controller: searchController,
            onChanged: onSearchChanged,
            onClear: onSearchCleared,
            query: searchQuery,
          ),
        ],
      ),
    );
  }
}
