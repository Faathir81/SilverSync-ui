import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_service.dart';
import '../../data/models/sync_log_model.dart';

// Holds the current sync job id and its live status
final activeSyncJobProvider = StateProvider<int?>((ref) => null);

// Polls status of the active sync job
final syncStatusProvider = FutureProvider.family<SyncLogModel, int>((ref, id) async {
  final api = ref.watch(apiServiceProvider);
  final response = await api.getSyncStatus(id.toString());
  if (response.statusCode == 200) {
    return SyncLogModel.fromJson(response.data);
  }
  throw Exception('Failed to get sync status');
});

// Initiates a sync and returns the created SyncLogModel
Future<SyncLogModel> initiateSync(ApiService api, String url) async {
  final response = await api.initiateSync(url);
  if (response.statusCode == 202) {
    return SyncLogModel.fromJson(response.data);
  }
  throw Exception('Failed to start sync: ${response.data}');
}
