import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_service.dart';
import '../../data/models/sync_log_model.dart';
import '../../../archive/presentation/providers/track_provider.dart';
import '../../../dashboard/presentation/providers/quota_provider.dart';
import '../../../../core/providers/notification_provider.dart';

/// Notifier that manages the active sync job and its polling state.
/// Persists across page switches and attempts to resume tracking on startup.
class SyncJobNotifier extends StateNotifier<SyncLogModel?> {
  final Ref ref;
  Timer? _pollTimer;

  SyncJobNotifier(this.ref) : super(null) {
    // Attempt to resume tracking if there are active jobs on the server
    _resumeActiveJobs();
  }

  Future<void> _resumeActiveJobs() async {
    try {
      final api = ref.read(apiServiceProvider);
      final response = await api.getActiveSyncs();
      if (response.statusCode == 200 && response.data is List) {
        final List logs = response.data;
        if (logs.isNotEmpty) {
          // Track the most recent active job
          final lastJob = SyncLogModel.fromJson(logs.last);
          state = lastJob;
          _startPolling(lastJob.id);
          ref.read(notificationProvider.notifier).show('RESUMING ACTIVE SYNC TRACKING...');
        }
      }
    } catch (_) {
      // Silent fail on resume check
    }
  }

  Future<void> startSync(String url) async {
    final api = ref.read(apiServiceProvider);
    
    _pollTimer?.cancel();
    state = null;

    try {
      final response = await api.initiateSync(url);
      if (response.statusCode == 202) {
        final job = SyncLogModel.fromJson(response.data);
        state = job;
        _startPolling(job.id);
        ref.read(notificationProvider.notifier).show('SYNC TASK INITIATED: #${job.id}');
      } else {
        throw Exception('Failed to start sync: ${response.data}');
      }
    } catch (e) {
      ref.read(notificationProvider.notifier).show('SYNC FAILED: $e', isError: true);
      rethrow;
    }
  }

  void _startPolling(int jobId) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      try {
        final api = ref.read(apiServiceProvider);
        final response = await api.getSyncStatus(jobId.toString());
        
        if (response.statusCode == 200) {
          final updated = SyncLogModel.fromJson(response.data);
          state = updated;

          if (updated.isDone || updated.isFailed) {
            _pollTimer?.cancel();
            
            if (updated.isDone) {
              ref.invalidate(tracksProvider);
              ref.invalidate(quotaProvider);
              ref.read(notificationProvider.notifier).show('LIBRARY UPDATED: NEW TRACKS ADDED');
            }
          }
        }
      } catch (_) {
        _pollTimer?.cancel();
      }
    });
  }

  void clear() {
    _pollTimer?.cancel();
    state = null;
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}

final activeSyncJobProvider = StateNotifierProvider<SyncJobNotifier, SyncLogModel?>((ref) {
  return SyncJobNotifier(ref);
});
