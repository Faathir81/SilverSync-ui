import '../../../archive/data/models/track_model.dart';

class PlaylistModel {
  final int id;
  final String name;
  final int trackCount;
  final List<TrackModel> tracks;

  PlaylistModel({
    required this.id,
    required this.name,
    this.trackCount = 0,
    this.tracks = const [],
  });

  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    final rawTracks = json['tracks'] as List?;
    final parsedTracks = rawTracks?.map((t) => TrackModel.fromJson(t as Map<String, dynamic>)).toList() ?? [];

    return PlaylistModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Untitled Set',
      trackCount: parsedTracks.length,
      tracks: parsedTracks,
    );
  }
}
