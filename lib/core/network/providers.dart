import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/presentation/auth_controller.dart';
import '../storage/preferences_storage.dart';
import '../storage/token_storage.dart';
import 'api_client.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(),
);

final tokenStorageProvider = Provider<SecureTokenStorage>((ref) {
  final backend = FlutterSecureStorageBackend(ref.watch(secureStorageProvider));
  return SecureTokenStorage(backend);
});

final sharedPreferencesProvider = FutureProvider<SharedPreferences>(
  (ref) => SharedPreferences.getInstance(),
);

final preferencesStorageProvider = Provider<PreferencesStorage?>((ref) {
  final prefsAsync = ref.watch(sharedPreferencesProvider);
  return prefsAsync.asData?.value == null
      ? null
      : PreferencesStorage(prefsAsync.asData!.value);
});

class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final preferences = ref.watch(preferencesStorageProvider);
    return preferences?.readThemeMode() ?? ThemeMode.system;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await ref.read(preferencesStorageProvider)?.writeThemeMode(mode);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);

final apiClientProvider = Provider<ApiClient>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  return ApiClient(
    tokenStorage: tokenStorage,
    onUnauthorized: () =>
        ref.read(authControllerProvider.notifier).handleUnauthorized(),
  );
});
