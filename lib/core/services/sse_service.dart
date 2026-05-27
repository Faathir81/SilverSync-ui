import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../../features/config/presentation/providers/preference_provider.dart';
import '../providers/notification_provider.dart';

final sseServiceProvider = Provider((ref) => SseService(ref));

class SseService {
  final Ref _ref;
  http.Client? _client;
  StreamSubscription? _subscription;

  SseService(this._ref);

  void startListening(BuildContext context) {
    if (_client != null) return; // Already listening

    _client = http.Client();
    final request = http.Request('GET', Uri.parse('${AppConstants.baseUrl}/api/v1/notifications/stream'));
    request.headers['Accept'] = 'text/event-stream';

    _client!.send(request).then((response) {
      if (response.statusCode != 200) {
        _stopListening();
        return;
      }
      _subscription = response.stream.transform(utf8.decoder).listen((data) {
        _handleEvent(context, data);
      }, onError: (err) {
        _stopListening();
      }, onDone: () {
        _stopListening();
      });
    }).catchError((_) {
      _stopListening();
    });
  }

  void _stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _client?.close();
    _client = null;
  }

  void _handleEvent(BuildContext context, String rawData) {
    final lines = rawData.split('\n');
    for (var line in lines) {
      if (line.startsWith('data: ')) {
        final jsonStr = line.substring(6).trim();
        if (jsonStr.isEmpty) continue;
        try {
          final data = jsonDecode(jsonStr);
          if (data['type'] == 'sync') {
            _showNotification(context, data['status'], data['message']);
          }
        } catch (_) {}
      }
    }
  }

  void _showNotification(BuildContext context, String status, String message) {
    // Only show if Push Notifications are enabled
    final prefs = _ref.read(preferenceProvider).value;
    if (prefs == null || !prefs.notificationsEnabled) return;

    final isError = status == 'FAILED';
    _ref.read(notificationProvider.notifier).show(message, isError: isError);
  }
}
