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
    final settings = _db.settings.get('app_settings');
    if (settings != null && settings is AppSettings) {
      state = settings;
    }
  }

  Future<void> updateSettings(AppSettings newSettings) async {
    await _db.settings.put('app_settings', newSettings);
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
}
