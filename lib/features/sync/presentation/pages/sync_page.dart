import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/providers/notification_provider.dart';

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
    } catch (e) {
      // Error handled by notifier
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentJob = ref.watch(activeSyncJobProvider);
    final watchListAsync = ref.watch(watchesProvider);

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
              _buildModuleHeader('SYNC // ENGINE_V2'),
            ],
          ),
        ),
        Container(height: 1, color: AppColors.primaryTeal.withOpacity(0.15)),

        // ═══════════════ SCROLLABLE CONTENT ═══════════════
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 180),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Input Card
                SyncInputCard(
                  urlController: _urlController,
                  isSubmitting: _isSubmitting,
                  onSync: _handleSync,
                ),
                
                const SizedBox(height: 30),
                _buildSectionHeader('ACTIVE MONITORING'),
                const SizedBox(height: 15),
                
                // Activity Card
                if (currentJob == null)
                  _buildEmptyActivityState()
                else
                  SyncActivityCard(
                    job: currentJob,
                    onDismiss: () => ref.read(activeSyncJobProvider.notifier).clear(),
                  ),
                
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionHeader('SMART WATCHER'),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, color: AppColors.primaryTeal, size: 20),
                      onPressed: _showAddWatchDialog,
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                
                // Watch List
                watchListAsync.when(
                  data: (watches) => _buildWatchList(watches),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => Center(child: Text('WATCHER OFFLINE', style: AppTheme.monoStyle(color: Colors.redAccent))),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModuleHeader(String title) {
    return Row(
      children: [
        Container(width: 4, height: 16, color: AppColors.primaryTeal),
        const SizedBox(width: 10),
        Text(title, style: AppTheme.monoStyle(fontSize: 12, color: AppColors.textMain)),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: AppTheme.monoStyle(fontSize: 10, color: AppColors.textMuted, letterSpacing: 2));
  }

  Widget _buildEmptyActivityState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.radar, size: 40, color: AppColors.primaryTeal.withOpacity(0.3)),
            const SizedBox(height: 15),
            Text('NO ACTIVE SYNC TASKS', style: AppTheme.monoStyle(fontSize: 14, color: AppColors.textMuted, letterSpacing: 2)),
          ],
        ),
      ),
    );
  }

  Widget _buildWatchList(List watches) {
    if (watches.isEmpty) {
      return Center(
        child: Text('NO PLAYLISTS WATCHED', style: AppTheme.monoStyle(fontSize: 10, color: AppColors.textMuted.withOpacity(0.5))),
      );
    }
    return Column(
      children: watches.map((w) => _buildWatchItem(w)).toList(),
    );
  }

  Widget _buildWatchItem(watch) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primaryTeal.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.playlist_play, color: AppColors.primaryMagenta, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(watch.name, style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(fontSize: 14)),
                const SizedBox(height: 2),
                Text('Last Sync: ${DateFormat('MMM dd, HH:mm').format(watch.lastSync)}',
                    style: AppTheme.monoStyle(fontSize: 9, color: AppColors.textMuted)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryTeal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text('ACTIVE', style: AppTheme.monoStyle(fontSize: 9, color: AppColors.primaryTeal)),
          ),
        ],
      ),
    );
  }

  void _showAddWatchDialog() {
    final watchUrlController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primaryTeal.withOpacity(0.3)),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ADD WATCH LIST', style: AppTheme.monoStyle(fontSize: 14, color: AppColors.primaryTeal, letterSpacing: 2)),
                const SizedBox(height: 20),
                TextField(
                  controller: watchUrlController,
                  style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(fontSize: 14),
                  decoration: const InputDecoration(
                    labelText: 'Spotify Playlist URL',
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primaryTeal)),
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
                      onPressed: () async {
                        final url = watchUrlController.text.trim();
                        if (url.isNotEmpty) {
                          final api = ref.read(apiServiceProvider);
                          await addWatch(api, ref, url);
                          if (mounted) Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryTeal),
                      child: const Text('ADD'),
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
