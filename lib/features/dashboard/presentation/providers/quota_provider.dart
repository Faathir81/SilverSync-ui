import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:silversync_ui/core/services/api_service.dart';
import '../../data/models/quota_model.dart';

final quotaProvider = FutureProvider<QuotaModel>((ref) async {
  final api = ref.watch(apiServiceProvider);
  try {
    final response = await api.getDriveQuota();
    if (response.statusCode == 200) {
      return QuotaModel.fromJson(response.data as Map<String, dynamic>);
    }
    throw Exception('Drive quota unavailable');
  } catch (e) {
    throw Exception('Google Drive not connected');
  }
});
