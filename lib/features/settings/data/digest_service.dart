import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/notification_service.dart';
import '../../../shared/providers/database_provider.dart';
import '../../insights/data/insights_providers.dart';
import 'notification_settings_provider.dart';

class DigestService {
  final ProviderRef ref;
  DigestService(this.ref);

  Future<void> checkAndFireDigest() async {
    final settings = ref.read(notificationSettingsProvider);
    if (!settings.weeklyDigest) return;

    final digest = ref.read(weeklyDigestProvider);
    if (digest == null) return;

    final db = ref.read(databaseProvider);
    final lastFired = db.settings.get('last_digest_date') as String?;
    final today = DateTime.now().toIso8601String().split('T')[0];

    if (lastFired != today) {
      await NotificationService().showNotification(
        id: 888,
        title: '📊 SUNDAY_STATUS_REPORT',
        body: digest.replaceFirst('SUNDAY_STATUS_REPORT:\n', ''),
        payload: '/insights',
      );
      await db.settings.put('last_digest_date', today);
    }
  }
}

final digestServiceProvider = Provider((ref) => DigestService(ref));
