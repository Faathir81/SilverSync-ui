import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/player/audio_player_provider.dart';
import '../../../../core/widgets/mini_player_widget.dart';
import '../../../../core/widgets/silver_sync_nav_bar.dart';
import '../../../../core/widgets/cached_album_art.dart';
import '../../../../core/services/api_service.dart';
import '../../../main/presentation/providers/main_nav_provider.dart';
import '../../../archive/presentation/widgets/track_list_item.dart';
import '../providers/playlist_provider.dart';

class PlaylistDetailPage extends ConsumerStatefulWidget {
  final int playlistId;
  final String playlistName;

  const PlaylistDetailPage({
    super.key,
    required this.playlistId,
    required this.playlistName,
  });

  @override
  ConsumerState<PlaylistDetailPage> createState() => _PlaylistDetailPageState();
}

class _PlaylistDetailPageState extends ConsumerState<PlaylistDetailPage> {
  static const double _expandedHeight = 340;
  late final ScrollController _scrollController;
  bool _showTitle = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        if (!_scrollController.hasClients) return;
        // Title becomes visible once the expanded section has scrolled away
        final collapsed = _scrollController.offset > (_expandedHeight - kToolbarHeight);
        if (collapsed != _showTitle) setState(() => _showTitle = collapsed);
      });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playlistAsync = ref.watch(playlistDetailProvider(widget.playlistId));
    final playerState = ref.watch(audioPlayerProvider);
    final player = ref.read(audioPlayerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: playlistAsync.when(
        data: (playlist) => CustomScrollView(
          controller: _scrollController,
          slivers: [
            // ── Functional Sliver Header ─────────────────────────────────────
            SliverAppBar(
              expandedHeight: _expandedHeight,
              pinned: true,
              backgroundColor: AppColors.background,
              elevation: 0,
              centerTitle: true,
              // Only show title when header is collapsed (scrolled past the cover)
              title: AnimatedOpacity(
                opacity: _showTitle ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Text(
                  playlist.name,
                  style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMain,
                  ),
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textMain, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.more_vert_rounded, color: AppColors.textMain),
                  onPressed: () => _showPlaylistOptions(context, ref, playlist),
                ),
                const SizedBox(width: 8),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  children: [
                    // Subtle Gradient
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.primaryTeal.withValues(alpha: 0.15),
                            AppColors.background,
                          ],
                        ),
                      ),
                    ),
                    // Core Info
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          Hero(
                            tag: 'playlist_${playlist.id}',
                            child: Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: playlist.tracks.isNotEmpty
                                    ? CachedAlbumArt(url: playlist.tracks.first.albumArtUrl, size: 180)
                                    : Container(
                                        color: AppColors.surface,
                                        child: const Icon(Icons.playlist_play_rounded, size: 64, color: AppColors.primaryTeal),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            playlist.name,
                            style: AppTheme.darkTheme.textTheme.displaySmall?.copyWith(fontSize: 26, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'STREAMING FROM GOOGLE DRIVE',
                            style: AppTheme.monoStyle(fontSize: 9, color: AppColors.primaryTeal.withValues(alpha: 0.6), letterSpacing: 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Play Control Row ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${playlist.tracks.length} TRACKS',
                          style: AppTheme.monoStyle(fontSize: 10, color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'PUBLIC COLLECTION',
                          style: AppTheme.monoStyle(fontSize: 8, color: AppColors.textMuted.withValues(alpha: 0.4)),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Actual Play Button
                    if (playlist.tracks.isNotEmpty)
                      GestureDetector(
                        onTap: () => player.playTrack(playlist.tracks.first, queue: playlist.tracks, startIndex: 0),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryTeal,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.play_arrow_rounded, color: Colors.black, size: 32),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // ── Track List ───────────────────────────────────────────────────
            if (playlist.tracks.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Text('EMPTY COLLECTION', style: AppTheme.monoStyle(fontSize: 11, color: AppColors.textMuted)),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final track = playlist.tracks[index];
                    final isPlaying = playerState.currentTrack?.id == track.id;

                    return TrackListItem(
                      track: track,
                      isPlaying: isPlaying,
                      onTap: () => player.playTrack(track, queue: playlist.tracks, startIndex: index),
                      onLongPress: () => _showTrackActions(context, ref, playlist.id, track),
                    );
                  },
                  childCount: playlist.tracks.length,
                ),
              ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 180)),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryTeal))),
        error: (err, _) => Center(child: Text('ERROR LOADING COLLECTION', style: AppTheme.monoStyle(color: Colors.redAccent))),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayerWidget(),
          const SizedBox(height: 8),
          SilverSyncNavBar(
            currentIndex: 3, // Collections is index 3
            onTap: (index) {
              if (index == 3) {
                // If they tap Collections again, just pop the detail page
                Navigator.pop(context);
              } else {
                // If they tap another tab, change global index and pop back to MainScreen
                ref.read(mainNavProvider.notifier).state = index;
                Navigator.popUntil(context, (route) => route.isFirst);
              }
            },
          ),
        ],
      ),
    );
  }

  void _showTrackActions(BuildContext context, WidgetRef ref, int playlistId, track) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
              title: Text('Remove from Collection', style: AppTheme.monoStyle(fontSize: 14, color: Colors.redAccent)),
              onTap: () {
                final api = ref.read(apiServiceProvider);
                removeTrackFromPlaylist(api, ref, playlistId, track.id);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showPlaylistOptions(BuildContext context, WidgetRef ref, playlist) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.edit_rounded, color: AppColors.textMain),
              title: Text('Rename Collection', style: AppTheme.monoStyle(fontSize: 14, color: AppColors.textMain)),
              onTap: () {
                Navigator.pop(context);
                _showRenameDialog(context, ref, playlist);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
              title: Text('Delete Collection', style: AppTheme.monoStyle(fontSize: 14, color: Colors.redAccent)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context, ref, playlist);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog(BuildContext context, WidgetRef ref, playlist) {
    final controller = TextEditingController(text: playlist.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceHigh,
        title: Text('Rename Collection', style: AppTheme.darkTheme.textTheme.bodyLarge),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: AppColors.textMain),
          decoration: const InputDecoration(
            hintText: 'Collection Name',
            hintStyle: TextStyle(color: AppColors.textMuted),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.surfaceBorder)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primaryTeal)),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName != playlist.name) {
                final api = ref.read(apiServiceProvider);
                await updatePlaylistMetadata(api, ref, playlist.id, newName);
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('SAVE', style: TextStyle(color: AppColors.primaryTeal)),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, playlist) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceHigh,
        title: Text('Delete Collection?', style: AppTheme.darkTheme.textTheme.bodyLarge),
        content: Text(
          'Are you sure you want to delete "${playlist.name}"? This action cannot be undone.',
          style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () async {
              final api = ref.read(apiServiceProvider);
              await deletePlaylistById(api, ref, playlist.id);
              if (context.mounted) {
                Navigator.pop(context); // close dialog
                Navigator.pop(context); // close detail page, go back to collections list
              }
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
