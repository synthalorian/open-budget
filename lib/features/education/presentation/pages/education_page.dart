import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/neon_ui_kit.dart';
import '../../../../core/domain/entities/education.dart';
import '../../data/education_providers.dart';

class EducationPage extends ConsumerWidget {
  const EducationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(educationContentProvider);
    final progress = ref.watch(userProgressProvider);
    final rank = ref.watch(userRankProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('THE DOJO', style: AppTextStyles.headlineMainframe),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.accent.withOpacity(0.5)),
                ),
                child: Text(rank, style: AppTextStyles.labelNeon.copyWith(fontSize: 8, color: AppColors.accent)),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.spaceGradient),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 120),
          children: [
            _buildSection(
              'STRATEGY_MODULES',
              content,
              progress,
              ref,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<EducationContent> items, Map<String, UserProgress> progressMap, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 4, height: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(title, style: AppTextStyles.labelNeon),
          ],
        ),
        const SizedBox(height: 16),
        ...items.map((item) {
          final p = progressMap[item.id] ?? UserProgress(contentId: item.id);
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildStrategyCard(item, p, ref, ref.context),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildStrategyCard(EducationContent item, UserProgress p, WidgetRef ref, BuildContext context) {
    final isDone = p.isCompleted;
    return NeonCard(
      glowColor: isDone ? AppColors.accent : AppColors.textMuted,
      opacity: 0.4,
      child: Column(
        children: [
          GestureDetector(
            onTap: () => context.push('/education/${item.id}'),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_getIcon(item.iconName), color: isDone ? AppColors.accent : AppColors.textMuted),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, style: AppTextStyles.headlineTitle.copyWith(fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(item.description, style: AppTextStyles.bodyMain.copyWith(fontSize: 12)),
                    ],
                  ),
                ),
                if (isDone)
                  const Icon(Icons.check_circle_rounded, color: AppColors.accent, size: 24)
                else
                  const Icon(Icons.lock_outline_rounded, size: 20, color: AppColors.textMuted),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => context.push('/education/${item.id}'),
              style: TextButton.styleFrom(
                backgroundColor: isDone 
                    ? AppColors.accent.withOpacity(0.1)
                    : AppColors.primary.withOpacity(0.1),
                side: BorderSide(color: isDone ? AppColors.accent : AppColors.primary),
              ),
              child: Text(
                isDone ? 'VIEW_DATA' : 'INITIALIZE_LEARNING',
                style: AppTextStyles.labelNeon.copyWith(fontSize: 10, color: isDone ? AppColors.accent : AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon(String name) {
    switch (name) {
      case 'shield_rounded': return Icons.shield_rounded;
      case 'gamepad_rounded': return Icons.gamepad_rounded;
      case 'qr_code_scanner_rounded': return Icons.qr_code_scanner_rounded;
      case 'auto_delete_rounded': return Icons.auto_delete_rounded;
      default: return Icons.school_rounded;
    }
  }
}
