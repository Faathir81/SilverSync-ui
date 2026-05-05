import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_service.dart';
import '../../data/models/watch_model.dart';

final watchesProvider = FutureProvider<List<WatchModel>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final response = await api.listWatch();
  
  if (response.statusCode == 200) {
    final List<dynamic> data = response.data;
    return data.map((json) => WatchModel.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load watch list');
  }
});

Future<void> addWatch(ApiService api, WidgetRef ref, String url) async {
  await api.addWatch(url);
  ref.invalidate(watchesProvider);
}
