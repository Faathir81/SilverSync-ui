import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_service.dart';
import 'track_provider.dart';


// ─── tracksProvider ───────────────────────────────────────────────────────────
// Kept in track_provider.dart. Re-exported here for convenience.
export 'track_provider.dart' show tracksProvider;

// ─── TrackMutations ───────────────────────────────────────────────────────────
// A collection of Riverpod-idiomatic async helpers for track mutations.
// These helpers run the API call and then invalidate [tracksProvider] so the
// list refreshes automatically — no manual setState required.

/// Toggles the favorite status of a track and refreshes the track list.
Future<void> toggleFavorite(
  ApiService api,
  WidgetRef ref,
  int trackId, {
  required bool newValue,
}) async {
  await api.toggleFavorite(trackId.toString(), isFavorite: newValue);
  ref.invalidate(tracksProvider);
}

/// Updates the title and artist of a track and refreshes the track list.
Future<void> updateTrackMetadata(
  ApiService api,
  WidgetRef ref,
  int trackId,
  String newTitle,
  String newArtist,
) async {
  await api.updateTrack(trackId.toString(), newTitle, newArtist);
  ref.invalidate(tracksProvider);
}

/// Deletes a track from the library and refreshes the track list.
Future<void> deleteTrack(ApiService api, WidgetRef ref, int trackId) async {
  await api.deleteTrack(trackId.toString());
  ref.invalidate(tracksProvider);
}
