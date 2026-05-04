import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_service.dart';
import '../../data/models/track_model.dart';

final tracksProvider = FutureProvider<List<TrackModel>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final response = await api.getTracks();

  if (response.statusCode == 200) {
    // Backend returns list directly or wrapped in { data: [...] }
    final raw = response.data;
    final List<dynamic> data = (raw is List) ? raw : (raw['data'] ?? raw['tracks'] ?? []);
    return data.map((json) => TrackModel.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load tracks');
  }
});

// Toggle favorite and refresh track list
Future<void> toggleFavorite(ApiService api, WidgetRef ref, int trackId, {required bool newValue}) async {
  await api.toggleFavorite(trackId.toString(), isFavorite: newValue);
  ref.invalidate(tracksProvider); // re-fetch after toggle
}
