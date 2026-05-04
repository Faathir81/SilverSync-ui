class PlaylistModel {
  final int id;
  final String name;
  final int trackCount;

  PlaylistModel({
    required this.id,
    required this.name,
    this.trackCount = 0,
  });

  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    return PlaylistModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Untitled Set',
      trackCount: (json['tracks'] as List?)?.length ?? 0,
    );
  }
}
