import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_service.dart';
import '../../../core/domain/entities/settings.dart';
import '../../../shared/providers/database_provider.dart';

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  final db = ref.watch(databaseProvider);
  return SettingsNotifier(db);
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  final DatabaseService _db;

  SettingsNotifier(this._db) : super(const AppSettings()) {
    _loadSettings();
  }

  void _loadSettings() {
    final collision = _db.settings.get('enableCollisionAlerts') as bool? ?? true;
    final critical = _db.settings.get('enableSystemCriticalAlerts') as bool? ?? true;
    final velocity = _db.settings.get('enableVelocityWarnings') as bool? ?? true;
    final currency = _db.settings.get('currencyCode') as String? ?? 'USD';
    final biometric = _db.settings.get('biometricEnabled') as bool? ?? false;
    final themeName = _db.settings.get('themeName') as String? ?? 'synthwave';
    final userName = _db.settings.get('userName') as String? ?? 'SYNTH_X_84';

    state = AppSettings(
      enableCollisionAlerts: collision,
      enableSystemCriticalAlerts: critical,
      enableVelocityWarnings: velocity,
      currencyCode: currency,
      biometricEnabled: biometric,
      themeName: themeName,
      userName: userName,
    );
  }

  Future<void> updateSettings(AppSettings newSettings) async {
    await _db.settings.put('enableCollisionAlerts', newSettings.enableCollisionAlerts);
    await _db.settings.put('enableSystemCriticalAlerts', newSettings.enableSystemCriticalAlerts);
    await _db.settings.put('enableVelocityWarnings', newSettings.enableVelocityWarnings);
    await _db.settings.put('currencyCode', newSettings.currencyCode);
    await _db.settings.put('biometricEnabled', newSettings.biometricEnabled);
    await _db.settings.put('themeName', newSettings.themeName);
    await _db.settings.put('userName', newSettings.userName);
    state = newSettings;
  }

  Future<void> toggleCollisionAlerts(bool value) async {
    final newSettings = state.copyWith(enableCollisionAlerts: value);
    await updateSettings(newSettings);
  }

  Future<void> toggleSystemCriticalAlerts(bool value) async {
    final newSettings = state.copyWith(enableSystemCriticalAlerts: value);
    await updateSettings(newSettings);
  }

  Future<void> toggleVelocityWarnings(bool value) async {
    final newSettings = state.copyWith(enableVelocityWarnings: value);
    await updateSettings(newSettings);
  }

  Future<void> toggleBiometrics(bool value) async {
    final newSettings = state.copyWith(biometricEnabled: value);
    await updateSettings(newSettings);
  }

  Future<void> setCurrency(String currencyCode) async {
    final newSettings = state.copyWith(currencyCode: currencyCode);
    await updateSettings(newSettings);
  }

  Future<void> setTheme(String themeName) async {
    final newSettings = state.copyWith(themeName: themeName);
    await updateSettings(newSettings);
  }

  Future<void> setUserName(String userName) async {
    final newSettings = state.copyWith(userName: userName);
    await updateSettings(newSettings);
  }
}
