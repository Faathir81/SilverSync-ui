import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/providers/notification_provider.dart';
import '../../../../core/services/audio_player_service.dart';
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

final playlistDetailProvider = FutureProvider.family<PlaylistModel, int>((ref, id) async {
  final api = ref.watch(apiServiceProvider);
  final response = await api.getPlaylistById(id.toString());

  if (response.statusCode == 200) {
    final raw = response.data;
    final data = (raw['data'] ?? raw['playlist'] ?? raw);
    return PlaylistModel.fromJson(data);
  } else {
    throw Exception('Failed to load playlist details');
  }
});

Future<void> createPlaylist(ApiService api, WidgetRef ref, String name) async {
  await api.createPlaylist(name);
  ref.read(notificationProvider.notifier).show('COLLECTION CREATED: ${name.toUpperCase()}');
  ref.invalidate(playlistsProvider);
}

Future<void> addTrackToPlaylist(ApiService api, WidgetRef ref, int playlistId, int trackId) async {
  await api.addTrackToPlaylist(playlistId.toString(), trackId.toString());
  ref.read(notificationProvider.notifier).show('TRACK ADDED TO COLLECTION');
  ref.invalidate(playlistsProvider);
  ref.invalidate(playlistDetailProvider(playlistId));
}

Future<void> removeTrackFromPlaylist(ApiService api, WidgetRef ref, int playlistId, int trackId) async {
  await api.removeTrackFromPlaylist(playlistId.toString(), trackId.toString());
  
  // Also clean up from player queue if user is currently playing this playlist
  ref.read(audioPlayerProvider.notifier).removeTrackFromQueue(trackId);
  
  ref.read(notificationProvider.notifier).show('TRACK REMOVED');
  ref.invalidate(playlistsProvider);
  ref.invalidate(playlistDetailProvider(playlistId));
}
