class WatchModel {
  final int id;
  final String spotifyId;
  final String name;
  final DateTime lastSync;

  WatchModel({
    required this.id,
    required this.spotifyId,
    required this.name,
    required this.lastSync,
  });

  factory WatchModel.fromJson(Map<String, dynamic> json) {
    return WatchModel(
      id: json['id'] ?? 0,
      spotifyId: json['spotify_id'] ?? '',
      name: json['name'] ?? 'Unknown Playlist',
      lastSync: json['last_sync'] != null ? DateTime.parse(json['last_sync']) : DateTime.now(),
    );
  }
}
