class SyncLogModel {
  final int id;
  final String spotifyUrl;
  final String status;
  final String message;
  final DateTime createdAt;

  SyncLogModel({
    required this.id,
    required this.spotifyUrl,
    required this.status,
    required this.message,
    required this.createdAt,
  });

  factory SyncLogModel.fromJson(Map<String, dynamic> json) {
    return SyncLogModel(
      id: json['ID'] ?? json['id'] ?? 0,
      spotifyUrl: json['SpotifyURL'] ?? json['spotify_url'] ?? '',
      status: json['Status'] ?? json['status'] ?? 'PENDING',
      message: json['Message'] ?? json['message'] ?? '',
      createdAt: DateTime.tryParse(json['CreatedAt'] ?? json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  bool get isDone => status == 'SUCCESS';
  bool get isFailed => status == 'FAILED';
  bool get isRunning => status == 'DOWNLOADING' || status == 'UPLOADING';
  bool get isPending => status == 'PENDING';
}
