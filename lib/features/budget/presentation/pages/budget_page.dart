import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/database_service.dart';
import '../../../../core/domain/entities/budget.dart';
import '../../../../core/domain/entities/category.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/neon_ui_kit.dart';
import '../../data/budget_providers.dart';
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
            icon: Icon(Icons.history_toggle_off_rounded, color: AppColors.accent),
            tooltip: 'CHRONOS_MODULE',
            onPressed: () => context.push('/recurring'),
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
        onPressed: () => _showAddBudgetSheet(context, ref, db),
        backgroundColor: AppColors.primary,
        child: Icon(Icons.add_rounded, size: 32),
      ),
    );
  }

  void _showAddBudgetSheet(BuildContext context, WidgetRef ref, DatabaseService db) {
    double amount = 0;
    BudgetPeriod period = BudgetPeriod.monthly;
    Category? selectedCategory;
    final List<Category> categories = db.categories.values
        .where((c) => c.type == CategoryType.expense)
        .toList();
    if (categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('NO EXPENSE CATEGORIES - OPEN CATEGORIES FIRST'),
          backgroundColor: AppColors.expense,
        ),
      );
      return;
    }
    selectedCategory = categories.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // DIAG v1.0.5: red background so we can tell if content area is zero-height.
                // Colored diagnostic strips between each major widget.
                diagStrip('A: start', Colors.yellow),
                Text('INITIALIZE_BUDGET', style: AppTextStyles.headlineMainframe.copyWith(fontSize: 18)),
                diagStrip('B: after title', Colors.cyan),
                const SizedBox(height: 24),
                TextField(
                  style: AppTextStyles.bodyMain,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration('AMOUNT', Icons.monetization_on_rounded),
                  onChanged: (val) => amount = double.tryParse(val) ?? 0,
                ),
                diagStrip('C: after amount field', Colors.lime),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<BudgetPeriod>(
                        value: period,
                        dropdownColor: AppColors.surface,
                        decoration: _inputDecoration('PERIOD', Icons.calendar_month_rounded),
                        items: BudgetPeriod.values.map<DropdownMenuItem<BudgetPeriod>>((p) => DropdownMenuItem<BudgetPeriod>(
                          value: p,
                          child: Text(p.name.toUpperCase(), style: const TextStyle(fontSize: 10)),
                        )).toList(),
                        onChanged: (val) => setState(() => period = val ?? BudgetPeriod.monthly),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: categories.isNotEmpty ? DropdownButtonFormField<Category>(
                        value: selectedCategory,
                        dropdownColor: AppColors.surface,
                        decoration: _inputDecoration('CATEGORY', Icons.category_rounded),
                        items: categories.map<DropdownMenuItem<Category>>((c) => DropdownMenuItem<Category>(
                          value: c,
                          child: Text(c.name.toUpperCase(), style: const TextStyle(fontSize: 10)),
                        )).toList(),
                        onChanged: (val) => setState(() => selectedCategory = val),
                      ) : Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(16),
                        child: Text('NO_EXPENSE_CATEGORIES_DETECTED', style: AppTextStyles.labelNeon.copyWith(color: AppColors.warning)),
                      ),
                    ),
                  ],
                ),
                diagStrip('D: after dropdowns', Colors.orange),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      if (amount > 0 && selectedCategory != null) {
                        final now = DateTime.now();
                        final budget = Budget(
                          id: const Uuid().v4(),
                          name: selectedCategory!.name,
                          amount: amount,
                          period: period,
                          type: BudgetType.category,
                          categoryId: selectedCategory!.id,
                          startDate: now,
                          createdAt: now,
                        );
                        ref.read(budgetNotifierProvider.notifier).createBudget(budget);
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    child: Text('COMMIT_BUDGET', style: AppTextStyles.labelNeon.copyWith(color: Colors.white)),
                  ),
                ),
                diagStrip('E: end', Colors.pink),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppTextStyles.labelNeon.copyWith(fontSize: 8, color: AppColors.textMuted),
      prefixIcon: Icon(icon, color: AppColors.accent, size: 20),
      filled: true,
      fillColor: AppColors.surfaceLight,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
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
                      color: categoryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: categoryColor.withValues(alpha: 0.3)),
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
                colors: [color.withValues(alpha: 0.5), color],
              ),
              borderRadius: BorderRadius.circular(3),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
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
    return NeonCard(
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
