import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/player/audio_player_provider.dart';
import '../../../../core/widgets/connection_error_widget.dart';
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
      backgroundColor: Colors.transparent,
      builder: (context) => TrackOptionsSheet(track: track),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tracksAsync = ref.watch(tracksProvider);
    final playerState = ref.watch(audioPlayerProvider);

    return Column(
      children: [
        // ── Header (non-sticky) ──────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Library', style: AppTheme.darkTheme.textTheme.displayLarge),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: tracksAsync.when(
                  data: (t) => TrackCountBadge(label: '${t.length} songs'),
                  loading: () => const TrackCountBadge(label: '...'),
                  error: (_, __) => const TrackCountBadge(label: 'Offline'),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── Sticky Search Bar ────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ArchiveSearchBar(
            controller: _searchController,
            onChanged: _onSearchChanged,
            onClear: _onSearchCleared,
            query: _searchQuery,
          ),
        ),

        const SizedBox(height: 8),

        // ── Track List (scrollable only) ─────────────────────────────────
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off_rounded, size: 48, color: AppColors.textTertiary),
                      const SizedBox(height: 12),
                      Text(
                        _searchQuery.isEmpty
                            ? 'No tracks in library'
                            : 'No results for "$_searchQuery"',
                        style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 180),
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
                  )
                      .animate()
                      .fade(duration: 350.ms)
                      .slideY(begin: 0.05, curve: Curves.easeOut);
                },
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
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
