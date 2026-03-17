import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/neon_ui_kit.dart';

class GoalsPage extends ConsumerWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('TARGETS', style: AppTextStyles.headlineMainframe),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.spaceGradient),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 120),
          children: [
            _buildGoalCard(
              'EMERGENCY FUND',
              'CRITICAL RESERVE',
              0.65,
              '\$6,500',
              '\$10,000',
              AppColors.accent,
            ),
            const SizedBox(height: 16),
            _buildGoalCard(
              'NEW WORKSTATION',
              'HARDWARE UPGRADE',
              0.15,
              '\$450',
              '\$3,000',
              AppColors.primary,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.track_changes_rounded, color: AppColors.background),
      ),
    );
  }

  Widget _buildGoalCard(
    String title,
    String subtitle,
    double progress,
    String current,
    String target,
    Color color,
  ) {
    return NeonCard(
      glowColor: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.headlineTitle.copyWith(fontSize: 16)),
                  Text(subtitle, style: AppTextStyles.labelNeon.copyWith(fontSize: 8, color: AppColors.textMuted)),
                ],
              ),
              const Icon(Icons.radar_rounded, color: AppColors.textMuted, size: 20),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(current, style: AppTextStyles.moneyLarge.copyWith(fontSize: 24, color: color)),
              Text('OF $target', style: AppTextStyles.labelNeon.copyWith(fontSize: 10)),
            ],
          ),
          const SizedBox(height: 12),
          _buildProgressBar(progress, color),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double progress, Color color) {
    return Stack(
      children: [
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        FractionallySizedBox(
          widthFactor: progress.clamp(0.0, 1.0),
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color.withOpacity(0.4), color]),
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.5), blurRadius: 8, spreadRadius: 1),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
