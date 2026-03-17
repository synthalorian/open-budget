import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/neon_ui_kit.dart';
import '../../data/notification_settings_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationSettings = ref.watch(notificationSettingsProvider);
    final notificationNotifier = ref.read(notificationSettingsProvider.notifier);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('CORE CONFIG', style: AppTextStyles.headlineMainframe),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.spaceGradient),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 120),
          children: [
            _buildSectionHeader('IDENTITY'),
            const SizedBox(height: 16),
            _buildSettingsItem('USER PROFILE', 'SYNTH_X_84', Icons.person_rounded, AppColors.primary),
            _buildSettingsItem('CURRENCY PROTOCOL', 'USD (\$)', Icons.monetization_on_rounded, AppColors.primary),
            
            const SizedBox(height: 32),
            _buildSectionHeader('ALERTS'),
            const SizedBox(height: 16),
            _buildToggleItem(
              'PROJECTION ALERTS',
              'AI collision detection',
              Icons.bolt_rounded,
              notificationSettings.projectionAlerts,
              (val) => notificationNotifier.updateSettings(projectionAlerts: val),
            ),
            const SizedBox(height: 12),
            _buildToggleItem(
              'DAILY REMINDERS',
              'Log transaction logs',
              Icons.notifications_active_rounded,
              notificationSettings.dailyReminders,
              (val) => notificationNotifier.updateSettings(dailyReminders: val),
            ),
            const SizedBox(height: 12),
            _buildToggleItem(
              'WEEKLY DIGEST',
              'Sunday data summary',
              Icons.summarize_rounded,
              notificationSettings.weeklyDigest,
              (val) => notificationNotifier.updateSettings(weeklyDigest: val),
            ),

            const SizedBox(height: 32),
            _buildSectionHeader('DATA MANAGEMENT'),
            const SizedBox(height: 16),
            _buildSettingsItem('EXPORT ARCHIVE', 'JSON / CSV', Icons.download_rounded, AppColors.accent),
            _buildSettingsItem('CLEAR MAIN FRAME', 'DESTRUCTIVE', Icons.delete_forever_rounded, AppColors.expense),
            const SizedBox(height: 32),
            _buildSectionHeader('SECURITY'),
            const SizedBox(height: 16),
            _buildSettingsItem('BIOMETRIC LOCK', 'ENCRYPTED', Icons.fingerprint_rounded, AppColors.accent),
            const SizedBox(height: 48),
            Center(
              child: Text(
                'OPEN_BUDGET v0.1.0\nBY SYNTHCLAW 🎹🦞',
                textAlign: TextAlign.center,
                style: AppTextStyles.labelNeon.copyWith(fontSize: 10, color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(width: 4, height: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyles.labelNeon),
      ],
    );
  }

  Widget _buildSettingsItem(String title, String value, IconData icon, Color color) {
    return NeonCard(
      padding: const EdgeInsets.all(16),
      opacity: 0.2,
      hasGlow: false,
      borderColor: AppColors.surfaceLight,
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.headlineTitle.copyWith(fontSize: 14)),
                const SizedBox(height: 4),
                Text(value, style: AppTextStyles.bodyMain.copyWith(fontSize: 10, color: color)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: 16),
        ],
      ),
    );
  }

  Widget _buildToggleItem(String title, String subtitle, IconData icon, bool value, Function(bool) onChanged) {
    return NeonCard(
      padding: const EdgeInsets.all(16),
      opacity: 0.2,
      hasGlow: value,
      glowColor: AppColors.accent,
      borderColor: value ? AppColors.accent.withOpacity(0.5) : AppColors.surfaceLight,
      child: Row(
        children: [
          Icon(icon, color: value ? AppColors.accent : AppColors.textMuted, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.headlineTitle.copyWith(fontSize: 14)),
                Text(subtitle, style: AppTextStyles.bodyMain.copyWith(fontSize: 10, color: AppColors.textMuted)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.accent,
            activeTrackColor: AppColors.accent.withOpacity(0.3),
            inactiveThumbColor: AppColors.textMuted,
            inactiveTrackColor: AppColors.surfaceLight,
          ),
        ],
      ),
    );
  }
}
