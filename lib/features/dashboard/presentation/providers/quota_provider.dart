import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:silversync_ui/core/services/api_service.dart';
import '../../data/models/quota_model.dart';

// ─── Auto-polling Quota Notifier ──────────────────────────────────────────────
// Polls every 30s and auto-reconnects when API comes back — no page refresh needed.
class QuotaNotifier extends AsyncNotifier<QuotaModel> {
  Timer? _timer;
  static const _pollInterval = Duration(seconds: 30);
  static const _retryInterval = Duration(seconds: 5); // fast retry when disconnected

  @override
  Future<QuotaModel> build() async {
    // Cancel any existing timer when provider rebuilds
    ref.onDispose(() => _timer?.cancel());
    _scheduleNext(connected: true);
    return _fetch();
  }

  Future<QuotaModel> _fetch() async {
    final api = ref.read(apiServiceProvider);
    final response = await api.getDriveQuota();
    if (response.statusCode == 200) {
      return QuotaModel.fromJson(response.data as Map<String, dynamic>);
    }
    throw Exception('Drive quota unavailable');
  }

  void _scheduleNext({required bool connected}) {
    _timer?.cancel();
    final interval = connected ? _pollInterval : _retryInterval;
    _timer = Timer(interval, () async {
      try {
        final quota = await _fetch();
        state = AsyncValue.data(quota);
        _scheduleNext(connected: true); // back to slow poll
      } catch (e) {
        state = AsyncValue.error(e, StackTrace.current);
        _scheduleNext(connected: false); // fast retry
      }
    });
  }

  /// Manual refresh (e.g. pull-to-refresh or retry button)
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final quota = await _fetch();
      state = AsyncValue.data(quota);
      _scheduleNext(connected: true);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      _scheduleNext(connected: false);
    }
  }
}

final quotaProvider = AsyncNotifierProvider<QuotaNotifier, QuotaModel>(
  QuotaNotifier.new,
);
