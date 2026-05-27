import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/api_service.dart';
import '../providers/playlist_provider.dart';
import '../../../../core/widgets/connection_error_widget.dart';
import '../widgets/playlist_list_item.dart';

class SetsPage extends ConsumerWidget {
  const SetsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistsAsync = ref.watch(playlistsProvider);

    return CustomScrollView(
      slivers: [
        // ── Header + FAB ──────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Collections', style: AppTheme.darkTheme.textTheme.displayLarge),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: GestureDetector(
                    onTap: () => _showCreateDialog(context, ref),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.add_rounded, color: AppColors.accent, size: 18),
                          const SizedBox(width: 4),
                          Text('New', style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w600,
                          )),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        // ── Playlists ──────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: playlistsAsync.when(
              data: (playlists) {
                if (playlists.isEmpty) {
                  return _EmptyState(onTap: () => _showCreateDialog(context, ref));
                }
                return Column(
                  children: playlists.map((pl) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: PlaylistListItem(playlist: pl),
                  )).toList(),
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                  ),
                ),
              ),
              error: (err, _) => ConnectionErrorWidget(
                message: err.toString(),
                onRetry: () => ref.invalidate(playlistsProvider),
              ),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 180)),
      ],
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceHigh,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.surfaceBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('New Collection', style: AppTheme.darkTheme.textTheme.displaySmall),
              const SizedBox(height: 6),
              Text('Give it a name.', style: AppTheme.darkTheme.textTheme.bodyMedium),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                autofocus: true,
                style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Collection name',
                  hintStyle: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  filled: true,
                  fillColor: Colors.black.withValues(alpha: 0.2),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.accent),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (controller.text.trim().isNotEmpty) {
                        createPlaylist(ref.read(apiServiceProvider), ref, controller.text.trim());
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Create', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onTap;
  const _EmptyState({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.add_rounded, size: 36, color: AppColors.accent),
          ),
          const SizedBox(height: 16),
          Text('No collections yet', style: AppTheme.darkTheme.textTheme.bodyLarge),
          const SizedBox(height: 4),
          Text('Create your first playlist collection', style: AppTheme.darkTheme.textTheme.bodyMedium),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Create Collection', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
