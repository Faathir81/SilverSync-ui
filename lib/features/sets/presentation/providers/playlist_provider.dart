import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_service.dart';
import '../../data/models/playlist_model.dart';

final playlistsProvider = FutureProvider<List<PlaylistModel>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final response = await api.getPlaylists();

  if (response.statusCode == 200) {
    final raw = response.data;
    final List<dynamic> data = (raw is List) ? raw : (raw['data'] ?? raw['playlists'] ?? []);
    return data.map((json) => PlaylistModel.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load playlists');
  }
});
