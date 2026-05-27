import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_service.dart';
import '../../data/models/preference_model.dart';

final preferenceProvider = AsyncNotifierProvider<PreferenceNotifier, PreferenceModel>(() {
  return PreferenceNotifier();
});

class PreferenceNotifier extends AsyncNotifier<PreferenceModel> {
  @override
  Future<PreferenceModel> build() async {
    return _fetchPreferences();
  }

  Future<PreferenceModel> _fetchPreferences() async {
    final api = ref.read(apiServiceProvider);
    final response = await api.getPreferences();
    return PreferenceModel.fromJson(response.data);
  }

  Future<void> updatePreferences(PreferenceModel newPrefs) async {
    final oldState = state;
    // Optimistic update — update UI immediately
    state = AsyncData(newPrefs);

    try {
      final api = ref.read(apiServiceProvider);
      await api.updatePreferences(newPrefs.toJson());
    } catch (e) {
      // Revert on error
      state = oldState;
      rethrow;
    }
  }

  Future<void> toggleApiHealth(bool value) async {
    if (state.value == null) return;
    await updatePreferences(state.value!.copyWith(apiHealthEnabled: value));
  }

  Future<void> toggleAutoSync(bool value) async {
    if (state.value == null) return;
    await updatePreferences(state.value!.copyWith(autoSyncEnabled: value));
  }

  Future<void> toggleNotifications(bool value) async {
    if (state.value == null) return;
    await updatePreferences(state.value!.copyWith(notificationsEnabled: value));
  }
}
