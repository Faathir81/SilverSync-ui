class PreferenceModel {
  final bool apiHealthEnabled;
  final bool autoSyncEnabled;
  final bool notificationsEnabled;

  PreferenceModel({
    required this.apiHealthEnabled,
    required this.autoSyncEnabled,
    required this.notificationsEnabled,
  });

  factory PreferenceModel.fromJson(Map<String, dynamic> json) {
    return PreferenceModel(
      apiHealthEnabled: json['apiHealthEnabled'] ?? true,
      autoSyncEnabled: json['autoSyncEnabled'] ?? true,
      notificationsEnabled: json['notificationsEnabled'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'apiHealthEnabled': apiHealthEnabled,
      'autoSyncEnabled': autoSyncEnabled,
      'notificationsEnabled': notificationsEnabled,
    };
  }

  PreferenceModel copyWith({
    bool? apiHealthEnabled,
    bool? autoSyncEnabled,
    bool? notificationsEnabled,
  }) {
    return PreferenceModel(
      apiHealthEnabled: apiHealthEnabled ?? this.apiHealthEnabled,
      autoSyncEnabled: autoSyncEnabled ?? this.autoSyncEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}
