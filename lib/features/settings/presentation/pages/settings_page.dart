import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/neon_ui_kit.dart';
import '../../data/notification_settings_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

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
            _buildSettingsItem(
              title: 'USER PROFILE',
              value: 'SYNTH_X_84',
              icon: Icons.person_rounded,
              color: AppColors.primary,
              onTap: null,
            ),
            _buildSettingsItem(
              title: 'CURRENCY PROTOCOL',
              value: 'USD (\$)',
              icon: Icons.monetization_on_rounded,
              color: AppColors.primary,
              onTap: null,
            ),
            
            const SizedBox(height: 32),
            _buildSectionHeader('MODULES'),
            const SizedBox(height: 16),
            _buildSettingsItem(
              title: 'SPENDING CATEGORIES',
              value: 'CUSTOMIZE DATA_MODULES',
              icon: Icons.category_rounded,
              color: AppColors.accent,
              onTap: () => context.push('/categories'),
            ),
            
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
            _buildSettingsItem(
              title: 'CLOUD_UPLINK',
              value: 'ENCRYPTED_SYNC',
              icon: Icons.cloud_sync_rounded,
              color: AppColors.accent,
              onTap: () => context.push('/cloud-sync'),
            ),
            _buildSettingsItem(
              title: 'EXPORT ARCHIVE',
              value: 'JSON / CSV',
              icon: Icons.download_rounded,
              color: AppColors.accent,
              onTap: () => context.push('/export'),
            ),
            _buildSettingsItem(
              title: 'CLEAR MAIN FRAME',
              value: 'DESTRUCTIVE',
              icon: Icons.delete_forever_rounded,
              color: AppColors.expense,
              onTap: null,
            ),

            const SizedBox(height: 32),
            _buildSectionHeader('SECURITY'),
            const SizedBox(height: 16),
            _buildSettingsItem(
              title: 'BIOMETRIC LOCK',
              value: 'ENCRYPTED',
              icon: Icons.fingerprint_rounded,
              color: AppColors.accent,
              onTap: null,
            ),

            const SizedBox(height: 32),
            _buildSectionHeader('DEVELOPMENT'),
            const SizedBox(height: 16),
            _buildSettingsItem(
              title: 'OPEN SOURCE',
              value: 'GITHUB_REPL_LINK',
              icon: Icons.code_rounded,
              color: AppColors.accent,
              onTap: () => _launchUrl('https://github.com/synthalorian/open-budget'),
            ),
            _buildSettingsItem(
              title: 'SUPPORT_UNIT',
              value: 'BUY_ME_A_COFFEE',
              icon: Icons.coffee_rounded,
              color: AppColors.income,
              onTap: () => _launchUrl('https://www.buymeacoffee.com/synthalorian'),
            ),

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

  Widget _buildSettingsItem({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: NeonCard(
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
              if (onTap != null)
                const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: 16),
            ],
          ),
        ),
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
