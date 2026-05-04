class QuotaModel {
  final String limit;
  final String usage;
  final String usageInDrive;
  final double usedPercentage;

  QuotaModel({
    required this.limit,
    required this.usage,
    required this.usageInDrive,
    required this.usedPercentage,
  });

  // API returns bytes, so we format them
  static String _formatBytes(dynamic bytes) {
    if (bytes == null) return '0 B';
    final b = (bytes is String) ? double.tryParse(bytes) ?? 0 : (bytes as num).toDouble();
    if (b >= 1e9) return '${(b / 1e9).toStringAsFixed(2)} GB';
    if (b >= 1e6) return '${(b / 1e6).toStringAsFixed(1)} MB';
    return '${(b / 1e3).toStringAsFixed(0)} KB';
  }

  // Aliases expected by UI widgets
  String get capacity => _formatBytes(null); // overridden below
  String get used => usage;
  String get free => limit;
  String get silversyncUsed => usageInDrive;

  factory QuotaModel.fromJson(Map<String, dynamic> json) {
    final limitBytes = (json['limit'] as num?)?.toDouble() ?? 0;
    final usageBytes = (json['usage'] as num?)?.toDouble() ?? 0;
    final driveBytes = (json['usageInDrive'] as num?)?.toDouble() ?? 0;
    final pct = limitBytes > 0 ? (usageBytes / limitBytes * 100) : 0.0;

    return QuotaModel(
      limit: _formatBytes(limitBytes),
      usage: _formatBytes(usageBytes),
      usageInDrive: _formatBytes(driveBytes),
      usedPercentage: pct,
    );
  }
}
