import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiServiceProvider = Provider((ref) => ApiService());

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://192.168.1.13:8080',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  Dio get client => _dio;

  // Health check
  Future<Response> ping() => _dio.get('/ping');

  // Auth - Spotify
  Future<Response> getSpotifyAuthStatus() => _dio.get('/auth/status');
  Future<Response> logoutSpotify() => _dio.get('/auth/logout');

  // Auth - Google Drive
  Future<Response> getGoogleAuthStatus() => _dio.get('/auth/google/status');
  Future<Response> logoutGoogle() => _dio.get('/auth/google/logout');

  // Sync Endpoints
  Future<Response> initiateSync(String url) => _dio.post('/api/v1/sync', data: {'url': url});
  Future<Response> getActiveSyncs() => _dio.get('/api/v1/sync/active');
  Future<Response> getSyncStatus(String id) => _dio.get('/api/v1/sync/status/$id');
  Future<Response> getDriveQuota() => _dio.get('/api/v1/sync/quota');

  // Smart Watcher
  Future<Response> addWatch(String url) => _dio.post('/api/v1/sync/watch', data: {'url': url});
  Future<Response> listWatch() => _dio.get('/api/v1/sync/watch');

  // Track Endpoints
  Future<Response> getTracks() => _dio.get('/api/v1/tracks');
  Future<Response> toggleFavorite(String id, {required bool isFavorite}) =>
      _dio.patch('/api/v1/tracks/$id/favorite', data: {'is_favorite': isFavorite});
  Future<Response> updateTrack(String id, String title, String artist) =>
      _dio.patch('/api/v1/tracks/$id', data: {'title': title, 'artist': artist});
  Future<Response> deleteTrack(String id) => _dio.delete('/api/v1/tracks/$id');

  // Playlist Endpoints
  Future<Response> getPlaylists() => _dio.get('/api/v1/playlists');
  Future<Response> getPlaylistById(String id) => _dio.get('/api/v1/playlists/$id');
  Future<Response> createPlaylist(String name) => _dio.post('/api/v1/playlists', data: {'name': name});
  Future<Response> addTrackToPlaylist(String playlistId, String trackId) =>
      _dio.post('/api/v1/playlists/$playlistId/tracks/$trackId');
  Future<Response> removeTrackFromPlaylist(String playlistId, String trackId) =>
      _dio.delete('/api/v1/playlists/$playlistId/tracks/$trackId');
}
