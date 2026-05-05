import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppNotificationState {
  final String message;
  final bool isVisible;
  final bool isError;

  AppNotificationState({this.message = '', this.isVisible = false, this.isError = false});

  AppNotificationState copyWith({String? message, bool? isVisible, bool? isError}) {
    return AppNotificationState(
      message: message ?? this.message,
      isVisible: isVisible ?? this.isVisible,
      isError: isError ?? this.isError,
    );
  }
}

class AppNotificationNotifier extends StateNotifier<AppNotificationState> {
  AppNotificationNotifier() : super(AppNotificationState());
  Timer? _timer;

  void show(String message, {bool isError = false}) {
    _timer?.cancel();
    state = AppNotificationState(message: message, isVisible: true, isError: isError);
    
    _timer = Timer(const Duration(seconds: 3), () {
      state = state.copyWith(isVisible: false);
    });
  }
}

final notificationProvider = StateNotifierProvider<AppNotificationNotifier, AppNotificationState>((ref) {
  return AppNotificationNotifier();
});
