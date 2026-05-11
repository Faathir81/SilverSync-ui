import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marquee/marquee.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/audio_player_service.dart';
import '../providers/track_provider.dart';
import '../../../../core/widgets/connection_error_widget.dart';
import '../widgets/track_list_item.dart';
import '../widgets/track_options_sheet.dart';

class ArchivePage extends ConsumerStatefulWidget {
  const ArchivePage({super.key});

  @override
  ConsumerState<ArchivePage> createState() => _ArchivePageState();
}

class _ArchivePageState extends ConsumerState<ArchivePage> {
  String searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tracksAsync = ref.watch(tracksProvider);
    final playerState = ref.watch(audioPlayerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ═══════════════ STICKY HEADER ═══════════════
        Container(
          color: AppColors.background,
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SYS // ACTIVE', style: AppTheme.monoStyle(fontSize: 12, color: AppColors.primaryTeal.withOpacity(0.7))),
              const SizedBox(height: 4),
              Text('SILVERSYNC', style: AppTheme.darkTheme.textTheme.displayLarge?.copyWith(
                shadows: [const Shadow(color: AppColors.primaryTeal, blurRadius: 10)],
              )),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ARCHIVE // SYNCED TRACKS', style: AppTheme.monoStyle(fontSize: 10, color: AppColors.primaryTeal.withOpacity(0.4), letterSpacing: 2)),
                      const SizedBox(height: 4),
                      Text('Library', style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(fontSize: 18)),
                    ],
                  ),
                  tracksAsync.when(
                    data: (tracks) => _buildBadge('${tracks.length} FILES'),
                    loading: () => _buildBadge('...'),
                    error: (_, __) => _buildBadge('OFFLINE'),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              _buildSearchBar(),
            ],
          ),
        ),
        Container(height: 1, color: AppColors.primaryTeal.withOpacity(0.15)),

        // ═══════════════ SCROLLABLE TRACK LIST ═══════════════
        Expanded(
          child: tracksAsync.when(
            data: (tracks) {
              final filtered = tracks.where((t) =>
                t.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
                t.artist.toLowerCase().contains(searchQuery.toLowerCase())
              ).toList();

              if (filtered.isEmpty) {
                return Center(
                  child: Text(
                    searchQuery.isEmpty ? 'NO TRACKS IN ARCHIVE' : 'NO RECORDS FOUND',
                    style: AppTheme.monoStyle(fontSize: 12, color: AppColors.primaryTeal.withOpacity(0.3), letterSpacing: 2),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 15, 16, 180),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final track = filtered[index];
                  final bool isPlaying = playerState.currentTrack?.id == track.id;

                  return TrackListItem(
                    track: track,
                    isPlaying: isPlaying,
                    onTap: () => ref.read(audioPlayerProvider.notifier).playTrack(track),
                    onLongPress: () => _showOptions(track),
                    buildMarquee: _buildSmartMarquee,
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryTeal))),
            error: (err, _) => ConnectionErrorWidget(
              message: err.toString(),
              onRetry: () => ref.invalidate(tracksProvider),
            ),
          ),
        ),
      ],
    );
  }

  void _showOptions(track) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => TrackOptionsSheet(track: track),
    );
  }

  Widget _buildSmartMarquee({required String text, required TextStyle style, double height = 20, bool isPlaying = false}) {
    // Only animate if playing to save CPU
    return SizedBox(
      height: height,
      child: isPlaying
          ? Marquee(
              text: text,
              style: style,
              scrollAxis: Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.start,
              blankSpace: 50.0,
              velocity: 30.0,
              pauseAfterRound: const Duration(seconds: 2),
              startPadding: 0,
              accelerationDuration: const Duration(seconds: 1),
              accelerationCurve: Curves.linear,
              decelerationDuration: const Duration(milliseconds: 500),
              decelerationCurve: Curves.easeOut,
            )
          : Text(
              text,
              style: style,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        border: Border.all(color: AppColors.primaryTeal.withOpacity(0.15)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => searchQuery = v),
        style: AppTheme.monoStyle(fontSize: 13, color: AppColors.textMain),
        decoration: InputDecoration(
          hintText: 'SEARCH_DATABASE...',
          hintStyle: AppTheme.monoStyle(fontSize: 12, color: AppColors.textMuted.withOpacity(0.3)),
          prefixIcon: Icon(Icons.search, size: 18, color: AppColors.primaryTeal.withOpacity(0.4)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => searchQuery = '');
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryTeal.withOpacity(0.1),
        border: Border.all(color: AppColors.primaryTeal.withOpacity(0.3)),
      ),
      child: Text(text, style: AppTheme.monoStyle(fontSize: 9, color: AppColors.primaryTeal, fontWeight: FontWeight.bold)),
    );
  }
}
