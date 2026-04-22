import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/neon_ui_kit.dart';
import '../../data/goal_providers.dart';
import '../../../../core/domain/entities/goal.dart';

class GoalsPage extends ConsumerWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsProgress = ref.watch(goalsWithProgressProvider);
    final completedGoals = ref.watch(completedGoalsProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('TARGETS', style: AppTextStyles.headlineMainframe),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.spaceGradient),
        child: goalsProgress.isEmpty && completedGoals.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.track_changes_rounded,
                        size: 64, color: AppColors.textMuted),
                    const SizedBox(height: 16),
                    Text('NO TARGETS SET',
                        style: AppTextStyles.headlineTitle
                            .copyWith(color: AppColors.textMuted)),
                    const SizedBox(height: 8),
                    Text('Create a savings goal to start tracking',
                        style: AppTextStyles.bodyMain
                            .copyWith(color: AppColors.textMuted)),
                  ],
                ),
              )
            : ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 120),
                children: [
                  if (goalsProgress.isNotEmpty) ...[
                    Text('ACTIVE TARGETS',
                        style: AppTextStyles.labelNeon
                            .copyWith(fontSize: 10)),
                    const SizedBox(height: 12),
                    ...goalsProgress.map((gp) =>
                        _buildGoalCard(context, ref, gp)),
                  ],
                  if (completedGoals.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text('COMPLETED',
                        style: AppTextStyles.labelNeon
                            .copyWith(fontSize: 10, color: AppColors.income)),
                    const SizedBox(height: 12),
                    ...completedGoals.map((g) =>
                        _buildCompletedCard(context, ref, g)),
                  ],
                  const SizedBox(height: 80),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/goals/add'),
        backgroundColor: AppColors.accent,
        child: Icon(Icons.add_rounded, color: AppColors.background),
      ),
    );
  }

  Widget _buildGoalCard(
      BuildContext context, WidgetRef ref, GoalProgress gp) {
    final goal = gp.goal;
    final color = Color(goal.color);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: NeonCard(
        glowColor: color,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(goal.name.toUpperCase(),
                          style: AppTextStyles.headlineTitle
                              .copyWith(fontSize: 16)),
                      if (gp.daysLeft != null)
                        Text(
                          '${gp.daysLeft} DAYS REMAINING',
                          style: AppTextStyles.labelNeon.copyWith(
                              fontSize: 8, color: AppColors.textMuted),
                        ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert,
                      color: AppColors.textMuted, size: 20),
                  onSelected: (value) {
                    if (value == 'add') {
                      _showAddFundsDialog(context, ref, goal);
                    } else if (value == 'delete') {
                      _confirmDelete(context, ref, goal);
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                        value: 'add', child: Text('Add Funds')),
                    const PopupMenuItem(
                        value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${goal.currentAmount.toStringAsFixed(2)}',
                  style: AppTextStyles.moneyLarge
                      .copyWith(fontSize: 24, color: color),
                ),
                Text(
                  'OF \$${goal.targetAmount.toStringAsFixed(0)}',
                  style: AppTextStyles.labelNeon.copyWith(fontSize: 10),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildProgressBar(goal.progress, color),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(gp.percentComplete).toStringAsFixed(0)}%',
                  style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
                if (gp.monthlyTarget != null)
                  Text(
                    '\$${gp.monthlyTarget!.toStringAsFixed(0)}/mo needed',
                    style: AppTextStyles.labelNeon.copyWith(
                        fontSize: 9,
                        color: gp.isOnTrack
                            ? AppColors.income
                            : AppColors.expense),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedCard(
      BuildContext context, WidgetRef ref, Goal goal) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NeonCard(
        glowColor: AppColors.income,
        child: Row(
          children: [
            Icon(Icons.check_circle_rounded,
                color: AppColors.income, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(goal.name.toUpperCase(),
                      style: AppTextStyles.headlineTitle
                          .copyWith(fontSize: 14)),
                  Text(
                    '\$${goal.targetAmount.toStringAsFixed(0)} achieved',
                    style: AppTextStyles.labelNeon.copyWith(
                        fontSize: 10, color: AppColors.income),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline,
                  color: AppColors.textMuted, size: 20),
              onPressed: () => _confirmDelete(context, ref, goal),
            ),
          ],
        ),
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
              gradient:
                  LinearGradient(colors: [color.withValues(alpha: 0.4), color]),
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 8,
                    spreadRadius: 1),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showAddFundsDialog(
      BuildContext context, WidgetRef ref, Goal goal) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('ADD FUNDS', style: AppTextStyles.headlineMainframe),
        content: TextField(
          controller: controller,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          style: AppTextStyles.moneyLarge,
          decoration: InputDecoration(
            hintText: '0.00',
            prefixText: '\$ ',
            hintStyle: TextStyle(color: AppColors.textMuted),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CANCEL', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(controller.text);
              if (amount != null && amount > 0) {
                ref
                    .read(goalNotifierProvider.notifier)
                    .addToGoal(goal.id, amount);
                Navigator.pop(ctx);
              }
            },
            child:
                Text('TRANSFER', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Goal goal) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('DELETE TARGET', style: AppTextStyles.headlineMainframe),
        content: Text('Delete "${goal.name}"? This cannot be undone.',
            style: AppTextStyles.bodyMain),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CANCEL', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              ref.read(goalNotifierProvider.notifier).deleteGoal(goal.id);
              Navigator.pop(ctx);
            },
            child: Text('DELETE',
                style: TextStyle(color: AppColors.expense)),
          ),
        ],
      ),
    );
  }
}
