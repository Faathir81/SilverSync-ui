import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';

final apiServiceProvider = Provider((ref) => ApiService());

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // ── Interceptors ────────────────────────────────────────────────────────
    _dio.interceptors.add(_LoggingInterceptor());
    _dio.interceptors.add(_ErrorNormalizingInterceptor());
  }

  Dio get client => _dio;

  // ── Health ─────────────────────────────────────────────────────────────────
  Future<Response> ping() => _dio.get('/ping');

  // ── Auth: Spotify ──────────────────────────────────────────────────────────
  Future<Response> getSpotifyAuthStatus() => _dio.get('/auth/status');
  Future<Response> logoutSpotify() => _dio.get('/auth/logout');

  // ── Auth: Google Drive ─────────────────────────────────────────────────────
  Future<Response> getGoogleAuthStatus() => _dio.get('/auth/google/status');
  Future<Response> logoutGoogle() => _dio.get('/auth/google/logout');

  // ── Sync ───────────────────────────────────────────────────────────────────
  Future<Response> initiateSync(String url) =>
      _dio.post('/api/v1/sync', data: {'url': url});
  Future<Response> getActiveSyncs() => _dio.get('/api/v1/sync/active');
  Future<Response> getSyncStatus(String id) =>
      _dio.get('/api/v1/sync/status/$id');
  Future<Response> getDriveQuota() => _dio.get('/api/v1/sync/quota');

  // ── Smart Watcher ──────────────────────────────────────────────────────────
  Future<Response> addWatch(String url) =>
      _dio.post('/api/v1/sync/watch', data: {'url': url});
  Future<Response> listWatch() => _dio.get('/api/v1/sync/watch');

  // ── Tracks ─────────────────────────────────────────────────────────────────
  Future<Response> getTracks({String? q, String? sort}) =>
      _dio.get('/api/v1/tracks', queryParameters: {
        if (q != null && q.isNotEmpty) 'q': q,
        if (sort != null) 'sort': sort,
      });

  Future<Response> toggleFavorite(String id, {required bool isFavorite}) =>
      _dio.patch('/api/v1/tracks/$id/favorite',
          data: {'is_favorite': isFavorite});

  Future<Response> updateTrack(String id, String title, String artist) =>
      _dio.patch('/api/v1/tracks/$id', data: {'title': title, 'artist': artist});

  Future<Response> deleteTrack(String id) => _dio.delete('/api/v1/tracks/$id');

  // ── Playlists ──────────────────────────────────────────────────────────────
  Future<Response> getPlaylists() => _dio.get('/api/v1/playlists');
  Future<Response> getPlaylistById(String id) =>
      _dio.get('/api/v1/playlists/$id');
  Future<Response> createPlaylist(String name) =>
      _dio.post('/api/v1/playlists', data: {'name': name});
  Future<Response> addTrackToPlaylist(String playlistId, String trackId) =>
      _dio.post('/api/v1/playlists/$playlistId/tracks/$trackId');
  Future<Response> removeTrackFromPlaylist(String playlistId, String trackId) =>
      _dio.delete('/api/v1/playlists/$playlistId/tracks/$trackId');
}

// ─── Interceptors ─────────────────────────────────────────────────────────────

/// Logs all requests and responses in debug mode.
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('[API] → ${options.method} ${options.path}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint(
        '[API] ← ${response.statusCode} ${response.requestOptions.path}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('[API] ✗ ${err.response?.statusCode} '
        '${err.requestOptions.path} — ${err.message}');
    handler.next(err);
  }
}

/// Normalizes DioExceptions into human-readable messages.
/// Downstream code can catch [ApiException] for user-facing error handling.
class _ErrorNormalizingInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String message;
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Connection timed out. Check your network.';
        break;
      case DioExceptionType.connectionError:
        message = 'Cannot reach server. Is the API running?';
        break;
      case DioExceptionType.badResponse:
        final code = err.response?.statusCode;
        final body = err.response?.data;
        message = body?['error'] ?? 'Server error ($code)';
        break;
      default:
        message = err.message ?? 'An unexpected error occurred.';
    }
    // Re-throw as a typed exception that widgets can catch
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: ApiException(message),
        type: err.type,
        response: err.response,
      ),
    );
  }
}

/// Typed exception for all API errors. Message is always user-readable.
class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}
