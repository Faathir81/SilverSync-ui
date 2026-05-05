import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/angular_container.dart';
import '../../../../core/widgets/cached_album_art.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/audio_player_service.dart';
import '../providers/track_provider.dart';
import '../../../sets/presentation/providers/playlist_provider.dart';
import '../../../../core/providers/notification_provider.dart';
import 'package:marquee/marquee.dart';

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ═══════════════════════════════════════════════════════════
        // STICKY HEADER — everything here stays fixed at the top
        // ═══════════════════════════════════════════════════════════
        Container(
          color: AppColors.background,
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Title ──
              Text('SYS // ACTIVE', style: AppTheme.monoStyle(fontSize: 12, color: AppColors.primaryTeal.withOpacity(0.7))),
              const SizedBox(height: 4),
              Text('SILVERSYNC', style: AppTheme.darkTheme.textTheme.displayLarge),
              const SizedBox(height: 25),

              // ── Subtitle + File Count ──
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
                    data: (tracks) => _buildFileBadge('${tracks.length} FILES', false),
                    loading: () => _buildFileBadge('LOADING...', false),
                    error: (_, __) => _buildFileBadge('OFFLINE', true),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // ── Search Bar ──
              _buildSearchBar(),
            ],
          ),
        ),

        // Divider line between header and list
        Container(height: 1, color: AppColors.primaryTeal.withOpacity(0.15)),

        // ═══════════════════════════════════════════════════════════
        // SCROLLABLE TRACK LIST — only this part scrolls
        // ═══════════════════════════════════════════════════════════
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
                padding: const EdgeInsets.fromLTRB(20, 15, 20, 180),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final track = filtered[index];
                  // Watch is outside itemBuilder call via closure — no extra rebuild per item
                  final currentTrackId = ref.watch(
                    audioPlayerProvider.select((s) => s.currentTrack?.id),
                  );
                  final isCurrentTrack = currentTrackId == track.id;
                  final isPlayingCurrent = isCurrentTrack &&
                      ref.watch(audioPlayerProvider.select((s) => s.isPlaying));
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () {
                        ref.read(audioPlayerProvider.notifier).playTrack(
                          track,
                          queue: filtered,
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: isCurrentTrack
                            ? BoxDecoration(
                                border: Border.all(
                                  color: AppColors.primaryTeal.withValues(alpha: 0.5),
                                  width: 1,
                                ),
                                color: AppColors.primaryTeal.withValues(alpha: 0.04),
                              )
                            : null,
                        child: AngularContainer(
                          cutSize: 6,
                          padding: EdgeInsets.zero,
                          child: _buildTrackItem(track, isPlaying: isPlayingCurrent),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryTeal),
              ),
            ),
            error: (err, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_off, size: 40, color: Colors.redAccent.withOpacity(0.4)),
                  const SizedBox(height: 15),
                  Text('DATABASE UNREACHABLE', style: AppTheme.monoStyle(fontSize: 12, color: Colors.redAccent.withOpacity(0.5), letterSpacing: 2)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Helper Widgets ─────────────────────────────────────────────

  Widget _buildFileBadge(String text, bool isError) {
    final color = isError ? Colors.redAccent : AppColors.primaryTeal;
    return AngularContainer(
      cutSize: 5,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Row(
        children: [
          Icon(isError ? Icons.warning : Icons.storage, size: 12, color: color),
          const SizedBox(width: 6),
          Text(text, style: AppTheme.monoStyle(fontSize: 10, color: color)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return AngularContainer(
      cutSize: 8,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Icon(Icons.search, size: 16, color: AppColors.primaryTeal.withOpacity(0.4)),
          const SizedBox(width: 10),
          Text('//', style: AppTheme.monoStyle(fontSize: 12, color: AppColors.primaryTeal.withOpacity(0.3))),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => searchQuery = val),
              style: AppTheme.monoStyle(fontSize: 14, color: AppColors.textMain),
              decoration: InputDecoration(
                hintText: 'SEARCH ARCHIVE...',
                hintStyle: AppTheme.monoStyle(fontSize: 14, color: AppColors.textMuted.withOpacity(0.5)),
                border: InputBorder.none,
              ),
            ),
          ),
          if (searchQuery.isNotEmpty)
            IconButton(
              icon: Icon(Icons.clear, size: 14, color: AppColors.textMuted.withOpacity(0.5)),
              onPressed: () {
                _searchController.clear();
                setState(() => searchQuery = '');
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }

  Widget _buildSmartMarquee({required String text, required TextStyle style, double height = 20}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final span = TextSpan(text: text, style: style);
        final tp = TextPainter(text: span, maxLines: 1, textDirection: TextDirection.ltr);
        tp.layout(maxWidth: constraints.maxWidth);

        if (tp.didExceedMaxLines) {
          // Text is too long, use Marquee
          return SizedBox(
            height: height,
            child: Marquee(
              text: text + "          ",
              style: style,
              scrollAxis: Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.start,
              blankSpace: 20.0,
              velocity: 30.0,
              pauseAfterRound: const Duration(seconds: 2),
              startPadding: 10.0,
              accelerationDuration: const Duration(seconds: 1),
              accelerationCurve: Curves.linear,
              decelerationDuration: const Duration(milliseconds: 500),
              decelerationCurve: Curves.easeOut,
            ),
          );
        } else {
          // Text fits, show normal text
          return Text(text, style: style, maxLines: 1, overflow: TextOverflow.ellipsis);
        }
      },
    );
  }

  Widget _buildTrackItem(track, {bool isPlaying = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      child: Row(
        children: [
          // Album art with playing indicator overlay
                // Album art — cached, no re-download on scroll
                CachedAlbumArt(
                  url: track.albumArtUrl,
                  size: 48,
                  isPlaying: isPlaying,
                ),
          const SizedBox(width: 15),

          // Title + Artist + Quality (3 Lines)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSmartMarquee(
                  text: track.title,
                  style: AppTheme.darkTheme.textTheme.bodyLarge!.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isPlaying ? AppColors.primaryTeal : AppColors.textMain,
                  ),
                  height: 18,
                ),
                const SizedBox(height: 2),
                _buildSmartMarquee(
                  text: track.artist,
                  style: AppTheme.monoStyle(fontSize: 11, color: AppColors.textMuted.withOpacity(0.8)),
                  height: 15,
                ),
                const SizedBox(height: 4),
                // Quality label (Static, but could be marquee if you want)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.primaryTeal.withOpacity(0.05),
                    border: Border.all(color: AppColors.primaryTeal.withOpacity(0.2)),
                  ),
                  child: Text(
                    (track.quality?.toLowerCase() ?? 'high'),
                    style: AppTheme.monoStyle(fontSize: 9, color: AppColors.primaryTeal.withOpacity(0.6), letterSpacing: 1),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 15), // Gap biar lega antara teks dan icon awan

          // Cloud status icon
          Icon(
            track.driveFileId.isNotEmpty ? Icons.cloud_done : Icons.cloud_off,
            size: 16,
            color: track.driveFileId.isNotEmpty
                ? AppColors.primaryTeal
                : AppColors.textMuted.withOpacity(0.3),
          ),
          const SizedBox(width: 4),

          // Favorite button
          IconButton(
            icon: Icon(
              track.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: track.isFavorite ? AppColors.primaryMagenta : AppColors.textMuted.withValues(alpha: 0.3),
              size: 20,
            ),
            onPressed: () {
              final api = ref.read(apiServiceProvider);
              toggleFavorite(api, ref, track.id, newValue: !track.isFavorite);
            },
          ),
          
          // More Options button
          IconButton(
            icon: Icon(Icons.more_vert, color: AppColors.textMuted.withValues(alpha: 0.5), size: 20),
            onPressed: () => _showTrackOptionsBottomSheet(context, ref, track),
          ),
        ],
      ),
    );
  }

  void _showTrackOptionsBottomSheet(BuildContext context, WidgetRef ref, track) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.textMuted.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.edit, color: AppColors.primaryMagenta),
                title: Text('Edit Metadata', style: AppTheme.monoStyle(fontSize: 14, color: AppColors.primaryMagenta)),
                onTap: () {
                  Navigator.pop(context);
                  _showEditMetadataDialog(context, ref, track);
                },
              ),
              ListTile(
                leading: const Icon(Icons.playlist_add, color: AppColors.primaryTeal),
                title: Text('Add to Collection', style: AppTheme.monoStyle(fontSize: 14, color: AppColors.textMain)),
                onTap: () {
                  Navigator.pop(context);
                  _showAddToPlaylistDialog(context, ref, track.id);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                title: Text('Delete from Library', style: AppTheme.monoStyle(fontSize: 14, color: Colors.redAccent)),
                onTap: () async {
                  Navigator.pop(context);
                  final api = ref.read(apiServiceProvider);
                  await api.deleteTrack(track.id.toString());
                  
                  // Clean up from active player queue if it's there
                  ref.read(audioPlayerProvider.notifier).removeTrackFromQueue(track.id);
                  
                  ref.read(notificationProvider.notifier).show('TRACK PERMANENTLY DELETED');
                  ref.invalidate(tracksProvider);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showAddToPlaylistDialog(BuildContext context, WidgetRef ref, int trackId) {
    final playlistsAsync = ref.read(playlistsProvider);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.background.withValues(alpha: 0.9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: AppColors.primaryTeal.withValues(alpha: 0.2)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textMuted.withValues(alpha: 0.3),
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
                        child: Text('NO COLLECTIONS FOUND', style: AppTheme.monoStyle(fontSize: 12, color: AppColors.textMuted)),
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
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.primaryTeal.withValues(alpha: 0.1)),
                          ),
                          child: const Icon(Icons.playlist_play_rounded, color: AppColors.primaryTeal, size: 20),
                        ),
                        title: Text(pl.name, style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(fontSize: 15)),
                        subtitle: Text('${pl.tracks.length} tracks', style: AppTheme.monoStyle(fontSize: 10, color: AppColors.textMuted)),
                        onTap: () {
                          final api = ref.read(apiServiceProvider);
                          addTrackToPlaylist(api, ref, pl.id, trackId);
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Text('Error: $err', style: const TextStyle(color: Colors.red)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showEditMetadataDialog(BuildContext context, WidgetRef ref, track) {
    final titleController = TextEditingController(text: track.title);
    final artistController = TextEditingController(text: track.artist);

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primaryMagenta.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(color: AppColors.primaryMagenta.withValues(alpha: 0.1), blurRadius: 20),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('EDIT METADATA', style: AppTheme.monoStyle(fontSize: 14, color: AppColors.primaryMagenta, letterSpacing: 2)),
                const SizedBox(height: 20),
                TextField(
                  controller: titleController,
                  style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Track Title',
                    labelStyle: AppTheme.monoStyle(fontSize: 10, color: AppColors.textMuted),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.textMuted.withValues(alpha: 0.3))),
                    focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primaryMagenta)),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: artistController,
                  style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Artist',
                    labelStyle: AppTheme.monoStyle(fontSize: 10, color: AppColors.textMuted),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.textMuted.withValues(alpha: 0.3))),
                    focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primaryMagenta)),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('CANCEL', style: AppTheme.monoStyle(fontSize: 12, color: AppColors.textMuted)),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryMagenta.withValues(alpha: 0.1),
                        foregroundColor: AppColors.primaryMagenta,
                        side: BorderSide(color: AppColors.primaryMagenta.withValues(alpha: 0.5)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      onPressed: () async {
                        final newTitle = titleController.text.trim();
                        final newArtist = artistController.text.trim();
                        if (newTitle.isNotEmpty && newArtist.isNotEmpty) {
                          final api = ref.read(apiServiceProvider);
                          ref.read(notificationProvider.notifier).show('UPDATING TRACK METADATA...');
                          await updateTrackMetadata(api, ref, track.id, newTitle, newArtist);
                          if (context.mounted) Navigator.pop(context);
                        }
                      },
                      child: Text('SAVE', style: AppTheme.monoStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
