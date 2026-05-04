import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:silversync_ui/core/services/api_service.dart';

class AuthStatus {
  final bool isSpotifyOnline;
  final bool isGoogleOnline;

  AuthStatus({this.isSpotifyOnline = false, this.isGoogleOnline = false});
}

final authStatusProvider = FutureProvider<AuthStatus>((ref) async {
  final api = ref.watch(apiServiceProvider);

  bool spotifyOnline = false;
  bool googleOnline = false;

  try {
    final spotifyRes = await api.getSpotifyAuthStatus();
    if (spotifyRes.statusCode == 200) {
      // Backend returns {"authenticated": true/false}
      spotifyOnline = spotifyRes.data['authenticated'] == true;
    }
  } catch (e) {
    // Keep false
  }

  try {
    final googleRes = await api.getGoogleAuthStatus();
    if (googleRes.statusCode == 200) {
      // Backend returns {"google_drive_authenticated": true/false}
      googleOnline = googleRes.data['google_drive_authenticated'] == true;
    }
  } catch (e) {
    // Keep false
  }

  return AuthStatus(isSpotifyOnline: spotifyOnline, isGoogleOnline: googleOnline);
});
