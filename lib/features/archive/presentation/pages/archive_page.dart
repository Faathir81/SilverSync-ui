import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/angular_container.dart';
import '../../../../core/services/api_service.dart';
import '../providers/track_provider.dart';

class ArchivePage extends ConsumerStatefulWidget {
  const ArchivePage({super.key});

  @override
  ConsumerState<ArchivePage> createState() => _ArchivePageState();
}

class _ArchivePageState extends ConsumerState<ArchivePage> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final tracksAsync = ref.watch(tracksProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 30),
          tracksAsync.when(
            data: (tracks) {
              final filtered = tracks.where((t) => 
                t.title.toLowerCase().contains(searchQuery.toLowerCase()) || 
                t.artist.toLowerCase().contains(searchQuery.toLowerCase())
              ).toList();
              return _buildContent(tracks.length, filtered);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => _buildContentWithError(err.toString()),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('SYS // ACTIVE', style: AppTheme.monoStyle(fontSize: 12, color: AppColors.primaryTeal.withOpacity(0.7))),
        const SizedBox(height: 4),
        Text('SILVERSYNC', style: AppTheme.darkTheme.textTheme.displayLarge),
      ],
    );
  }

  Widget _buildContent(int totalTracks, List filteredTracks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            AngularContainer(
              cutSize: 5,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.storage, size: 12, color: AppColors.primaryTeal),
                  const SizedBox(width: 6),
                  Text('$totalTracks FILES', style: AppTheme.monoStyle(fontSize: 10, color: AppColors.primaryTeal)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildSearchBar(),
        const SizedBox(height: 20),
        AngularContainer(
          padding: const EdgeInsets.all(0), // List items will have their own padding
          child: filteredTracks.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text('NO RECORDS FOUND', style: AppTheme.monoStyle(fontSize: 12, color: AppColors.primaryTeal.withOpacity(0.3), letterSpacing: 2)),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredTracks.length,
                  separatorBuilder: (context, index) => Divider(color: AppColors.primaryTeal.withOpacity(0.12), height: 1),
                  itemBuilder: (context, index) => _buildTrackItem(filteredTracks[index]),
                ),
        ),
      ],
    );
  }

  Widget _buildContentWithError(String error) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            AngularContainer(
              cutSize: 5,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.warning, size: 12, color: Colors.redAccent),
                  const SizedBox(width: 6),
                  Text('OFFLINE', style: AppTheme.monoStyle(fontSize: 10, color: Colors.redAccent)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildSearchBar(),
        const SizedBox(height: 20),
        AngularContainer(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Center(
            child: Text('DATABASE UNREACHABLE', style: AppTheme.monoStyle(fontSize: 12, color: Colors.redAccent.withOpacity(0.5), letterSpacing: 2)),
          ),
        ),
      ],
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
              onChanged: (val) => setState(() => searchQuery = val),
              style: AppTheme.monoStyle(fontSize: 14, color: AppColors.textMain),
              decoration: InputDecoration(
                hintText: 'SEARCH ARCHIVE...',
                hintStyle: AppTheme.monoStyle(fontSize: 14, color: AppColors.textMuted.withOpacity(0.5)),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackItem(track) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primaryTeal.withOpacity(0.2)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(0),
              child: Image.network(
                track.albumArtUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => Container(
                  color: Colors.white10,
                  child: const Icon(Icons.music_note, color: Colors.white24),
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(track.title, style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                Row(
                  children: [
                    Text(track.artist, style: AppTheme.monoStyle(fontSize: 10, color: AppColors.textMuted.withOpacity(0.7))),
                    const SizedBox(width: 8),
                    Text(track.quality ?? 'HIGH', style: AppTheme.monoStyle(fontSize: 10, color: AppColors.primaryTeal.withOpacity(0.5))),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            track.driveFileId.isNotEmpty ? Icons.cloud_done : Icons.cloud_off,
            size: 16,
            color: track.driveFileId.isNotEmpty ? AppColors.primaryTeal : AppColors.textMuted.withOpacity(0.3),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: Icon(
              track.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: track.isFavorite ? AppColors.primaryMagenta : AppColors.textMuted.withOpacity(0.3),
              size: 20,
            ),
            onPressed: () {
              final api = ref.read(apiServiceProvider);
              toggleFavorite(api, ref, track.id);
            },
          ),
        ],
      ),
    );
  }
}
