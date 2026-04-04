import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/neon_ui_kit.dart';
import '../../../../core/services/backup_service.dart';

class CloudSyncPage extends ConsumerWidget {
  const CloudSyncPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.chevron_left_rounded, color: AppColors.accent),
          onPressed: () => context.pop(),
        ),
        title: Text('ENCRYPTED_UPLINK', style: AppTextStyles.headlineMainframe.copyWith(fontSize: 20)),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.spaceGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('DATA_SOVEREIGNTY'),
              const SizedBox(height: 16),
              Text(
                'Your data never leaves your device unencrypted. Create secure backups and restore them anywhere.',
                style: AppTextStyles.bodyMain.copyWith(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              _buildSectionHeader('EXPORT_PROTOCOL'),
              const SizedBox(height: 16),
              NeonCard(
                glowColor: AppColors.accent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.cloud_upload_rounded, color: AppColors.accent, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('CREATE_ENCRYPTED_BACKUP', style: AppTextStyles.headlineTitle.copyWith(fontSize: 14)),
                              Text('AES-256 encrypted archive', style: AppTextStyles.labelNeon.copyWith(fontSize: 8, color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final backupService = BackupService();
                          final file = await backupService.createEncryptedBackup();
                          if (context.mounted) {
                            await Share.shareXFiles(
                              [XFile(file.path)],
                              subject: 'Open Budget Backup - ${DateTime.now().toIso8601String().split('T')[0]}',
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: AppColors.background,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('INITIALIZE_UPLINK', style: AppTextStyles.labelNeon.copyWith(color: AppColors.background)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _buildSectionHeader('IMPORT_PROTOCOL'),
              const SizedBox(height: 16),
              NeonCard(
                glowColor: AppColors.primary,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.cloud_download_rounded, color: AppColors.primary, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('RESTORE_FROM_BACKUP', style: AppTextStyles.headlineTitle.copyWith(fontSize: 14)),
                              Text('Decrypts and imports data', style: AppTextStyles.labelNeon.copyWith(fontSize: 8, color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final result = await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['bin'],
                          );
                          if (result != null && result.files.single.path != null) {
                            final file = File(result.files.single.path!);
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: AppColors.surface,
                                title: Text('RESTORE_DATA?', style: AppTextStyles.labelNeon.copyWith(color: AppColors.warning)),
                                content: Text(
                                  'This will replace all current data with the backup. This action cannot be undone.',
                                  style: AppTextStyles.bodyMain,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: Text('CANCEL', style: AppTextStyles.labelNeon.copyWith(color: AppColors.textMuted)),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: Text('RESTORE', style: AppTextStyles.labelNeon.copyWith(color: AppColors.warning)),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed == true && context.mounted) {
                              try {
                                await BackupService().restoreFromBackup(file);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('DATA_RESTORED_SUCCESSFULLY'),
                                      backgroundColor: AppColors.income,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('RESTORE_FAILED: $e'),
                                      backgroundColor: AppColors.expense,
                                    ),
                                  );
                                }
                              }
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('DOWNLOAD_FROM_CLOUD', style: AppTextStyles.labelNeon.copyWith(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              Center(
                child: Column(
                  children: [
                    Icon(Icons.lock_rounded, color: AppColors.textMuted, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      'ZERO_KNOWLEDGE_ENCRYPTION\nYOUR_DATA_NEVER_LEAVES_YOUR_DEVICE_UNENCRYPTED',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.labelNeon.copyWith(fontSize: 8, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(width: 4, height: 16, color: AppColors.accent),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyles.labelNeon),
      ],
    );
  }
}
