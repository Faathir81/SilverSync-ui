class QuotaModel {
  final double limitBytes;
  final double usageBytes;
  final double usageInDriveBytes;
  final double silversyncBytes;

  QuotaModel({
    required this.limitBytes,
    required this.usageBytes,
    required this.usageInDriveBytes,
    this.silversyncBytes = 0.0,          // ← default 0.0 so it's never null
  });

  static String _formatBytes(double b) {
    if (b >= 1e12) return '${(b / 1e12).toStringAsFixed(2)} TB';
    if (b >= 1e9) return '${(b / 1e9).toStringAsFixed(2)} GB';
    if (b >= 1e6) return '${(b / 1e6).toStringAsFixed(1)} MB';
    if (b >= 1e3) return '${(b / 1e3).toStringAsFixed(0)} KB';
    return '${b.toStringAsFixed(0)} B';
  }

  String get capacity => _formatBytes(limitBytes);
  String get used => _formatBytes(usageBytes);
  String get free => _formatBytes(limitBytes - usageBytes);

  // Shows real SilverSync folder size (from backend calculation)
  String get silversyncUsed => _formatBytes(silversyncBytes);

  // Gauge percentage based on total account usage vs limit
  double get usedPercentage => limitBytes > 0 ? (usageBytes / limitBytes * 100) : 0.0;

  // Full string with unit for gauge center (e.g. "12.67 GB")
  String get usedShort => _formatBytes(usageBytes);

  factory QuotaModel.fromJson(Map<String, dynamic> json) {
    double parse(dynamic val) {
      if (val == null) return 0.0;           // explicit 0.0 (double), not 0 (int)
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    return QuotaModel(
      limitBytes: parse(json['limit']),
      usageBytes: parse(json['usage']),
      usageInDriveBytes: parse(json['usageInDrive']),
      silversyncBytes: parse(json['silversyncBytes']), // 0.0 if key missing (old backend)
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'limit': limitBytes,
      'usage': usageBytes,
      'usageInDrive': usageInDriveBytes,
      'silversyncBytes': silversyncBytes,
    };
  }
}
