import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/neon_ui_kit.dart';
import '../../data/budget_providers.dart';
import '../../../transactions/data/transaction_providers.dart';
import '../../../../shared/providers/database_provider.dart';

class BudgetPage extends ConsumerWidget {
  const BudgetPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryBudgets = ref.watch(categoryBudgetsProvider);
    final totalUsage = ref.watch(totalBudgetUsageProvider);
    final budgetUsage = ref.watch(budgetUsageProvider);
    final db = ref.watch(databaseProvider);
    final currencyFormat = NumberFormat.simpleCurrency(decimalDigits: 0);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('MAIN FRAME', style: AppTextStyles.headlineMainframe),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.accent),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.spaceGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPulseDashboard(totalUsage, currencyFormat),
              const SizedBox(height: 48),
              _buildGridHeader('MEMORY MODULES'),
              const SizedBox(height: 16),
              if (categoryBudgets.isEmpty)
                _buildEmptyState()
              else
                ...categoryBudgets.map((budget) {
                  final usage = budgetUsage[budget.categoryId];
                  final category = db.categories.get(budget.categoryId);
                  return _buildModuleCard(budget, usage, category, currencyFormat);
                }).toList(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded, size: 32),
      ),
    );
  }

  Widget _buildPulseDashboard(BudgetUsage? totalUsage, NumberFormat currency) {
    final spent = totalUsage?.spent ?? 0;
    final budget = totalUsage?.budget.amount ?? 0;
    final percentUsed = totalUsage?.percentUsed ?? 0;

    return Center(
      child: Column(
        children: [
          NeonPulseOrb(
            percentUsed: percentUsed,
            baseColor: AppColors.primary,
          ),
          const SizedBox(height: 24),
          Text(
            currency.format(spent),
            style: AppTextStyles.moneyLarge.copyWith(color: AppColors.accent),
          ),
          Text(
            'SPENT OF ${currency.format(budget)}',
            style: AppTextStyles.labelNeon.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildGridHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          color: AppColors.accent,
        ),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyles.labelNeon),
      ],
    );
  }

  Widget _buildModuleCard(
    dynamic budget,
    BudgetUsage? usage,
    dynamic category,
    NumberFormat currency,
  ) {
    final spent = usage?.spent ?? 0;
    final budgetAmount = budget.amount;
    final isOver = usage?.isOverBudget ?? false;
    final categoryColor = Color(category?.color ?? 0xFF9D50BB);

    return NeonCard(
      glowColor: isOver ? AppColors.expense : categoryColor,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: categoryColor.withOpacity(0.3)),
                    ),
                    child: Icon(
                      _getIcon(category?.iconName ?? 'more_horiz'),
                      color: categoryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    category?.name ?? 'Unknown',
                    style: AppTextStyles.headlineTitle.copyWith(fontSize: 16),
                  ),
                ],
              ),
              Text(
                currency.format(spent),
                style: AppTextStyles.headlineTitle.copyWith(
                  fontSize: 16,
                  color: isOver ? AppColors.expense : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildProgressBar(usage?.percentUsed ?? 0, categoryColor, isOver),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SYSTEM HEALTH',
                style: AppTextStyles.labelNeon.copyWith(
                  fontSize: 8,
                  color: isOver ? AppColors.expense : AppColors.textMuted,
                ),
              ),
              Text(
                'LIMIT: ${currency.format(budgetAmount)}',
                style: AppTextStyles.labelNeon.copyWith(
                  fontSize: 8,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double progress, Color color, bool isOver) {
    return Stack(
      children: [
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        FractionallySizedBox(
          widthFactor: progress.clamp(0.0, 1.0),
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.5), color],
              ),
              borderRadius: BorderRadius.circular(3),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const NeonCard(
      child: Center(
        child: Text('NO MEMORY MODULES DETECTED'),
      ),
    );
  }

  IconData _getIcon(String name) {
    const iconMap = {
      'restaurant': Icons.restaurant_menu_rounded,
      'directions_car': Icons.directions_car_filled_rounded,
      'shopping_bag': Icons.shopping_bag_rounded,
      'more_horiz': Icons.more_horiz_rounded,
    };
    return iconMap[name] ?? Icons.grid_view_rounded;
  }
}
