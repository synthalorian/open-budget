import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/neon_ui_kit.dart';
import '../../data/education_providers.dart';

class EducationDetailPage extends ConsumerWidget {
  final String contentId;

  const EducationDetailPage({super.key, required this.contentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contents = ref.watch(educationContentProvider);
    final item = contents.firstWhere((e) => e.id == contentId);
    final progress = ref.watch(userProgressProvider)[contentId];
    final isDone = progress?.isCompleted ?? false;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, color: AppColors.accent),
          onPressed: () => context.pop(),
        ),
        title: Text('DATA_CONSOLE', style: AppTextStyles.labelNeon),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.spaceGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NeonCard(
                glowColor: AppColors.primary,
                child: Column(
                  children: [
                    Icon(_getIcon(item.iconName), size: 48, color: AppColors.accent),
                    const SizedBox(height: 16),
                    Text(
                      item.title,
                      style: AppTextStyles.headlineMainframe.copyWith(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                      ),
                      child: Text(
                        item.difficulty.name.toUpperCase(),
                        style: AppTextStyles.labelNeon.copyWith(fontSize: 10),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text('TRANSMISSION_START', style: AppTextStyles.labelNeon.copyWith(color: AppColors.textMuted)),
              const SizedBox(height: 16),
              NeonCard(
                opacity: 0.1,
                hasGlow: false,
                borderColor: AppColors.surfaceLight,
                child: Text(
                  item.content,
                  style: AppTextStyles.bodyMain.copyWith(height: 1.8),
                ),
              ),
              const SizedBox(height: 32),
              if (!isDone)
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () async {
                      await ref.read(educationNotifierProvider.notifier).completeModule(item.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('LEARNING_PROTOCOL_COMPLETE: RANK_SYNCHRONIZED'),
                            backgroundColor: AppColors.income,
                          ),
                        );
                        context.pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.background,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text('COMPLETE_MODULE', style: AppTextStyles.labelNeon.copyWith(color: AppColors.background)),
                  ),
                )
              else
                Center(
                  child: Column(
                    children: [
                      const Icon(Icons.verified_rounded, color: AppColors.income, size: 48),
                      const SizedBox(height: 8),
                      Text('MODULE_ARCHIVED', style: AppTextStyles.labelNeon.copyWith(color: AppColors.income)),
                    ],
                  ),
                ),
              const SizedBox(height: 48),
              Text('TRANSMISSION_END', style: AppTextStyles.labelNeon.copyWith(color: AppColors.textMuted)),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIcon(String name) {
    switch (name) {
      case 'shield_rounded': return Icons.shield_rounded;
      case 'gamepad_rounded': return Icons.gamepad_rounded;
      case 'qr_code_scanner_rounded': return Icons.qr_code_scanner_rounded;
      case 'auto_delete_rounded': return Icons.auto_delete_rounded;
      case 'trending_up_rounded': return Icons.trending_up_rounded;
      case 'bolt_rounded': return Icons.bolt_rounded;
      default: return Icons.school_rounded;
    }
  }
}
