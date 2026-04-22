import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neon_themes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/domain/entities/settings.dart';
import '../../../../shared/widgets/neon_ui_kit.dart';
import '../../data/notification_settings_provider.dart';
import '../../data/settings_providers.dart';
import '../../../../core/services/security_service.dart';
import '../../../../main.dart' show lastFlutterError;
import '../../data/export_service.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationSettings = ref.watch(notificationSettingsProvider);
    final notificationNotifier = ref.read(notificationSettingsProvider.notifier);
    final appSettings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

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
              context,
              'USER PROFILE',
              appSettings.userName,
              Icons.person_rounded,
              AppColors.primary,
              null,
              onTap: () => _showUserNameEditor(context, settingsNotifier, appSettings),
            ),
            _buildCurrencySelector(context, settingsNotifier, appSettings),
            
            const SizedBox(height: 32),
            _buildSectionHeader('AESTHETICS'),
            const SizedBox(height: 16),
            _buildThemeSelector(context, settingsNotifier, appSettings),

            const SizedBox(height: 32),
            _buildSectionHeader('MODULES'),
            const SizedBox(height: 16),
            _buildSettingsItem(context, 'SPENDING_CATEGORIES', 'CUSTOMIZE DATA_MODULES', Icons.category_rounded, AppColors.accent, '/categories'),
            _buildSettingsItem(context, 'CHRONOS_MODULE', 'RECURRING_TRANSACTIONS', Icons.history_toggle_off_rounded, AppColors.accent, '/recurring'),
            
            const SizedBox(height: 32),
            _buildSectionHeader('ALERTS'),
            const SizedBox(height: 16),
            _buildToggleItem(
              'PROJECTION_ALERTS',
              'AI collision detection',
              Icons.bolt_rounded,
              notificationSettings.projectionAlerts,
              (val) => notificationNotifier.updateSettings(projectionAlerts: val),
            ),
            const SizedBox(height: 12),
            _buildToggleItem(
              'DAILY_REMINDERS',
              'Log transaction prompts',
              Icons.notifications_active_rounded,
              notificationSettings.dailyReminders,
              (val) => notificationNotifier.updateSettings(dailyReminders: val),
            ),
            const SizedBox(height: 12),
            _buildToggleItem(
              'WEEKLY_DIGEST',
              'Sunday data summary',
              Icons.summarize_rounded,
              notificationSettings.weeklyDigest,
              (val) => notificationNotifier.updateSettings(weeklyDigest: val),
            ),

            const SizedBox(height: 32),
            _buildSectionHeader('DATA_MANAGEMENT'),
            const SizedBox(height: 16),
            _buildSettingsItem(context, 'CLOUD_UPLINK', 'ENCRYPTED_SYNC', Icons.cloud_sync_rounded, AppColors.accent, '/cloud-sync'),
            _buildSettingsItem(context, 'EXPORT_ARCHIVE', 'JSON / CSV', Icons.download_rounded, AppColors.accent, '/export'),
            _buildSettingsItem(
              context,
              'CLEAR_MAIN_FRAME',
              'DESTRUCTIVE',
              Icons.delete_forever_rounded,
              AppColors.expense,
              null,
              onTap: () => showClearDataDialog(context, ref),
            ),
            _buildSettingsItem(
              context,
              'VIEW_LAST_ERROR',
              lastFlutterError.isEmpty ? 'NO ERRORS CAPTURED' : 'TAP TO VIEW',
              Icons.bug_report_rounded,
              AppColors.warning,
              null,
              onTap: () => _showLastError(context),
            ),
            
            const SizedBox(height: 32),
            _buildSectionHeader('SECURITY'),
            const SizedBox(height: 16),
            _buildBiometricToggle(context, settingsNotifier, appSettings.biometricEnabled),
            
            const SizedBox(height: 32),
            _buildSectionHeader('OPEN_SOURCE'),
            const SizedBox(height: 16),
            _buildSettingsItem(context, 'GITHUB_REPOSITORY', 'github.com/synthalorian/open-budget', Icons.code_rounded, AppColors.primary, null, url: 'https://github.com/synthalorian/open-budget'),
            _buildSettingsItem(context, 'SUPPORT_DEVELOPMENT', 'buymeacoffee.com/synthalorian', Icons.coffee_rounded, AppColors.warning, null, url: 'https://buymeacoffee.com/synthalorian'),
            
            const SizedBox(height: 48),
            Center(
              child: Text(
                'OPEN_BUDGET v1.0.6\nBY SYNTH AND SYNTHCLAW 🎹🦞',
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

  Widget _buildSettingsItem(BuildContext context, String title, String value, IconData icon, Color color, String? route, {String? url, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap ?? () async {
        if (url != null) {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        } else if (route != null) {
          context.push(route);
        }
      },
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
              if (route != null || url != null)
                Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleItem(String title, String subtitle, IconData icon, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: NeonCard(
        padding: const EdgeInsets.all(16),
        opacity: 0.2,
        hasGlow: value,
        glowColor: AppColors.accent,
        borderColor: value ? AppColors.accent.withValues(alpha: 0.5) : AppColors.surfaceLight,
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
              activeThumbColor: AppColors.accent,
              activeTrackColor: AppColors.accent.withValues(alpha: 0.3),
              inactiveThumbColor: AppColors.textMuted,
              inactiveTrackColor: AppColors.surfaceLight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBiometricToggle(BuildContext context, SettingsNotifier notifier, bool isEnabled) {
    return FutureBuilder<bool>(
      future: SecurityService().isBiometricAvailable(),
      builder: (context, snapshot) {
        final isAvailable = snapshot.data ?? false;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: NeonCard(
            padding: const EdgeInsets.all(16),
            opacity: 0.2,
            hasGlow: isEnabled,
            glowColor: AppColors.accent,
            borderColor: isEnabled ? AppColors.accent : AppColors.surfaceLight,
            child: Row(
              children: [
                Icon(Icons.fingerprint_rounded, color: isEnabled ? AppColors.accent : AppColors.textMuted, size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('BIOMETRIC_FIREWALL', style: AppTextStyles.headlineTitle.copyWith(fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(
                        isAvailable ? (isEnabled ? 'ACTIVE_ENCRYPTION' : 'TAP_TO_ENABLE') : 'NO_HARDWARE_DETECTED',
                        style: AppTextStyles.bodyMain.copyWith(fontSize: 10, color: isEnabled ? AppColors.accent : AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isEnabled,
                  onChanged: isAvailable ? (val) => notifier.toggleBiometrics(val) : null,
                  activeThumbColor: AppColors.accent,
                  activeTrackColor: AppColors.accent.withValues(alpha: 0.3),
                  inactiveThumbColor: AppColors.textMuted,
                  inactiveTrackColor: AppColors.surfaceLight,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurrencySelector(BuildContext context, SettingsNotifier notifier, AppSettings settings) {
    final currencies = AppConstants.supportedCurrencies;
    return _buildSettingsItem(
      context, 
      'CURRENCY_PROTOCOL', 
      '${settings.currencyCode} (${settings.currencySymbol})', 
      Icons.monetization_on_rounded, 
      AppColors.primary, 
      null,
      onTap: () => _showCurrencySelector(context, notifier, settings, currencies),
    );
  }

  Widget _buildThemeSelector(BuildContext context, SettingsNotifier notifier, AppSettings settings) {
    final currentTheme = NeonThemes.byName(settings.themeName);
    return _buildSettingsItem(
      context, 
      'VISUAL_INTERFACE', 
      currentTheme.displayName, 
      Icons.palette_rounded, 
      AppColors.primary, 
      null,
      onTap: () => _showThemeSelector(context, notifier, settings),
    );
  }

  void _showLastError(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('LAST_ERROR', style: AppTextStyles.labelNeon.copyWith(color: AppColors.warning)),
        content: SingleChildScrollView(
          child: SelectableText(
            lastFlutterError.isEmpty ? 'No errors captured since app start.' : lastFlutterError,
            style: AppTextStyles.bodyMain.copyWith(fontSize: 11),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CLOSE', style: TextStyle(color: AppColors.textMuted)),
          ),
        ],
      ),
    );
  }

  void _showUserNameEditor(BuildContext context, SettingsNotifier notifier, AppSettings settings) {
    final controller = TextEditingController(text: settings.userName);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('REASSIGN_IDENTITY', style: AppTextStyles.headlineMainframe.copyWith(fontSize: 18)),
            const SizedBox(height: 24),
            TextField(
              controller: controller,
              autofocus: true,
              style: AppTextStyles.bodyMain,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                labelText: 'USER_HANDLE',
                labelStyle: AppTextStyles.labelNeon.copyWith(fontSize: 8, color: AppColors.textMuted),
                prefixIcon: Icon(Icons.person_rounded, color: AppColors.accent, size: 20),
                filled: true,
                fillColor: AppColors.surfaceLight,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  final name = controller.text.trim();
                  if (name.isNotEmpty) {
                    notifier.setUserName(name);
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: Text('COMMIT_IDENTITY', style: AppTextStyles.labelNeon.copyWith(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCurrencySelector(BuildContext context, SettingsNotifier notifier, AppSettings settings, Map<String, String> currencies) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SELECT_CURRENCY_PROTOCOL', style: AppTextStyles.headlineMainframe.copyWith(fontSize: 18)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: currencies.length,
                itemBuilder: (context, index) {
                  final code = currencies.keys.elementAt(index);
                  final symbol = currencies[code]!;
                  final isSelected = code == settings.currencyCode;
                  
                  return GestureDetector(
                    onTap: () {
                      notifier.setCurrency(code);
                      Navigator.pop(context);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary.withValues(alpha: 0.2) : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(symbol, style: AppTextStyles.moneyLarge.copyWith(fontSize: 20)),
                          const SizedBox(width: 16),
                          Text(code, style: AppTextStyles.headlineTitle.copyWith(fontSize: 14)),
                          const Spacer(),
                          if (isSelected)
                            Icon(Icons.check_circle_rounded, color: AppColors.accent),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeSelector(BuildContext context, SettingsNotifier notifier, AppSettings settings) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SELECT_INTERFACE_SKIN', style: AppTextStyles.headlineMainframe.copyWith(fontSize: 18)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: NeonThemes.all.length,
                itemBuilder: (context, index) {
                  final theme = NeonThemes.all[index];
                  final isSelected = theme.name == settings.themeName;
                  
                  return GestureDetector(
                    onTap: () {
                      notifier.setTheme(theme.name);
                      Navigator.pop(context);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected ? theme.primary.withValues(alpha: 0.2) : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? theme.primary : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: theme.primary,
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: theme.primary.withValues(alpha: 0.5), blurRadius: 8)],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(theme.displayName, style: AppTextStyles.headlineTitle.copyWith(fontSize: 14)),
                              Text(theme.description, style: AppTextStyles.bodyMain.copyWith(fontSize: 10, color: AppColors.textMuted)),
                            ],
                          ),
                          const Spacer(),
                          if (isSelected)
                            Icon(Icons.check_circle_rounded, color: theme.accent),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
