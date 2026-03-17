import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_service.dart';
import '../../../shared/providers/database_provider.dart';

class NotificationSettings {
  final bool projectionAlerts;
  final bool dailyReminders;
  final bool weeklyDigest;
  final bool onboardingComplete;

  const NotificationSettings({
    this.projectionAlerts = true,
    this.dailyReminders = false,
    this.weeklyDigest = true,
    this.onboardingComplete = false,
  });

  NotificationSettings copyWith({
    bool? projectionAlerts,
    bool? dailyReminders,
    bool? weeklyDigest,
    bool? onboardingComplete,
  }) {
    return NotificationSettings(
      projectionAlerts: projectionAlerts ?? this.projectionAlerts,
      dailyReminders: dailyReminders ?? this.dailyReminders,
      weeklyDigest: weeklyDigest ?? this.weeklyDigest,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    );
  }
}

final notificationSettingsProvider = StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>((ref) {
  final db = ref.watch(databaseProvider);
  return NotificationSettingsNotifier(db);
});

class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  final DatabaseService _db;

  NotificationSettingsNotifier(this._db) : super(const NotificationSettings()) {
    _loadSettings();
  }

  void _loadSettings() {
    final projection = _db.settings.get('projection_alerts') as bool? ?? true;
    final daily = _db.settings.get('daily_reminders') as bool? ?? false;
    final weekly = _db.settings.get('weekly_digest') as bool? ?? true;
    
    state = NotificationSettings(
      projectionAlerts: projection,
      dailyReminders: daily,
      weeklyDigest: weekly,
    );
  }

  Future<void> updateSettings({
    bool? projectionAlerts,
    bool? dailyReminders,
    bool? weeklyDigest,
  }) async {
    if (projectionAlerts != null) {
      await _db.settings.put('projection_alerts', projectionAlerts);
    }
    if (dailyReminders != null) {
      await _db.settings.put('daily_reminders', dailyReminders);
    }
    if (weeklyDigest != null) {
      await _db.settings.put('weekly_digest', weeklyDigest);
    }
    
    state = state.copyWith(
      projectionAlerts: projectionAlerts,
      dailyReminders: dailyReminders,
      weeklyDigest: weeklyDigest,
    );
  }
}
