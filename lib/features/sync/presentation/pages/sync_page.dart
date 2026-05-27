import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/api_service.dart';
import '../providers/sync_provider.dart';
import '../providers/watch_provider.dart';
import '../widgets/sync_input_card.dart';
import '../widgets/sync_activity_card.dart';
import 'package:intl/intl.dart';

class SyncPage extends ConsumerStatefulWidget {
  const SyncPage({super.key});

  @override
  ConsumerState<SyncPage> createState() => _SyncPageState();
}

class _SyncPageState extends ConsumerState<SyncPage> {
  final _urlController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _handleSync() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;
    setState(() => _isSubmitting = true);
    try {
      await ref.read(activeSyncJobProvider.notifier).startSync(url);
      _urlController.clear();
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentJob = ref.watch(activeSyncJobProvider);
    final watchListAsync = ref.watch(watchesProvider);

    return CustomScrollView(
      slivers: [
        // ── Header ──────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            child: Text('Sync', style: AppTheme.darkTheme.textTheme.displayLarge),
          ),
        ),

        // ── Input Card ───────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SyncInputCard(
              urlController: _urlController,
              isSubmitting: _isSubmitting,
              onSync: _handleSync,
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 32)),

        // ── Active Job ───────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
            child: AppTheme.sectionLabel('Active Job'),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: currentJob == null
                ? _EmptyState(
                    icon: Icons.sync_rounded,
                    message: 'No active sync running',
                    sub: 'Paste a Spotify playlist URL above to start',
                  )
                : SyncActivityCard(
                    job: currentJob,
                    onDismiss: () => ref.read(activeSyncJobProvider.notifier).clear(),
                  ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 32)),

        // ── Watch List ───────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 16, 0),
            child: Row(
              children: [
                Expanded(child: AppTheme.sectionLabel('Smart Watcher')),
                IconButton(
                  icon: const Icon(Icons.add_rounded, color: AppColors.accent, size: 22),
                  onPressed: _showAddWatchDialog,
                  tooltip: 'Add playlist to watch',
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: watchListAsync.when(
              data: (watches) => watches.isEmpty
                  ? _EmptyState(
                      icon: Icons.visibility_rounded,
                      message: 'No playlists watched',
                      sub: 'Watched playlists sync automatically',
                    )
                  : Column(
                      children: watches.map((w) => _WatchItem(watch: w)).toList(),
                    ),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(AppColors.accent),
                  ),
                ),
              ),
              error: (_, __) => _EmptyState(
                icon: Icons.error_outline_rounded,
                message: 'Could not load watcher',
                sub: 'Check your API connection',
              ),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 180)),
      ],
    );
  }

  void _showAddWatchDialog() {
    final watchUrlController = TextEditingController();
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceHigh,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.surfaceBorder),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add Playlist', style: AppTheme.darkTheme.textTheme.displaySmall),
              const SizedBox(height: 6),
              Text('Paste a Spotify playlist URL to watch.', style: AppTheme.darkTheme.textTheme.bodyMedium),
              const SizedBox(height: 20),
              TextField(
                controller: watchUrlController,
                autofocus: true,
                style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'https://open.spotify.com/playlist/...',
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
                    child: Text('Cancel', style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      final url = watchUrlController.text.trim();
                      if (url.isNotEmpty) {
                        final api = ref.read(apiServiceProvider);
                        await addWatch(api, ref, url);
                        if (mounted) Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Add', style: TextStyle(fontWeight: FontWeight.w600)),
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

// ── Empty State ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String sub;
  const _EmptyState({required this.icon, required this.message, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(icon, size: 36, color: AppColors.textTertiary),
          const SizedBox(height: 12),
          Text(message, style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(sub, style: AppTheme.darkTheme.textTheme.bodyMedium, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ── Watch Item ────────────────────────────────────────────────────────────────
class _WatchItem extends StatelessWidget {
  final dynamic watch;
  const _WatchItem({required this.watch});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
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
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(watch.name, style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(fontSize: 15)),
                const SizedBox(height: 2),
                Text(
                  'Last sync: ${DateFormat('MMM dd, HH:mm').format(watch.lastSync)}',
                  style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accentGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Active',
              style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                color: AppColors.accentGreen,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
