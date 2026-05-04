class TrackModel {
  final int id;
  final String spotifyId;
  final String title;
  final String artist;
  final String driveFileId;
  final String albumArtUrl;
  final bool isFavorite;
  final String quality;
  final DateTime createdAt;

  TrackModel({
    required this.id,
    required this.spotifyId,
    required this.title,
    required this.artist,
    required this.driveFileId,
    required this.albumArtUrl,
    required this.isFavorite,
    required this.quality,
    required this.createdAt,
  });

  factory TrackModel.fromJson(Map<String, dynamic> json) {
    return TrackModel(
      id: json['id'] ?? 0,
      spotifyId: json['spotify_id'] ?? '',
      title: json['title'] ?? 'Unknown Title',
      artist: json['artist'] ?? 'Unknown Artist',
      driveFileId: json['drive_file_id'] ?? '',
      albumArtUrl: json['album_art_url'] ?? '',
      isFavorite: json['is_favorite'] ?? false,
      quality: json['quality'] ?? 'high',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}
