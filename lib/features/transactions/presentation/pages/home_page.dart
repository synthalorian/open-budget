import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/neon_ui_kit.dart';
import '../../data/transaction_providers.dart';
import '../../../insights/data/insights_providers.dart';
import '../../../../shared/providers/database_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(balanceProvider);
    final income = ref.watch(currentMonthIncomeProvider);
    final expenses = ref.watch(currentMonthExpensesProvider);
    final transactions = ref.watch(transactionsProvider);
    final insights = ref.watch(spendingInsightsProvider);
    final db = ref.watch(databaseProvider);
    final currencyFormat = NumberFormat.simpleCurrency(decimalDigits: 0);
    final healthScore = ref.watch(healthScoreProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('THE GRID', style: AppTextStyles.headlineMainframe),
        actions: [
          IconButton(
            icon: const Icon(Icons.bolt_rounded, color: AppColors.accent),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.spaceGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCoreBalance(balance, income, expenses, currencyFormat, healthScore),
              const SizedBox(height: 32),
              _buildSectionHeader('QUICK ACCESS'),
              const SizedBox(height: 16),
              _buildActionGrid(context),
              const SizedBox(height: 32),
              _buildSectionHeader('RECENT DATA'),
              const SizedBox(height: 16),
              if (transactions.isEmpty)
                _buildEmptyState()
              else
                ...transactions.take(5).map((t) {
                  final category = db.categories.get(t.categoryId);
                  return _buildTransactionCard(t, category, currencyFormat);
                }).toList(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-transaction'),
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add_rounded, color: AppColors.background, size: 32),
      ),
    );
  }

  Widget _buildCoreBalance(double balance, double income, double expenses, NumberFormat currency, int healthScore) {
    return NeonCard(
      glowColor: AppColors.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TOTAL LIQUIDITY', style: AppTextStyles.labelNeon.copyWith(fontSize: 10)),
              _buildHealthBadge(healthScore),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            currency.format(balance),
            style: AppTextStyles.moneyLarge.copyWith(color: AppColors.accent),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildStatRow('INFLOW', currency.format(income), AppColors.income),
              ),
              Container(width: 1, height: 30, color: AppColors.surfaceLight),
              Expanded(
                child: _buildStatRow('OUTFLOW', currency.format(expenses), AppColors.expense),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthBadge(int score) {
    final color = score > 80 
        ? AppColors.income 
        : score > 50 
            ? AppColors.warning 
            : AppColors.expense;
            
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text('HEALTH: $score%', style: AppTextStyles.labelNeon.copyWith(fontSize: 8, color: color)),
    );
  }

  Widget _buildStatRow(String label, String amount, Color color) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.labelNeon.copyWith(fontSize: 8, color: AppColors.textMuted)),
        Text(amount, style: AppTextStyles.headlineTitle.copyWith(fontSize: 18, color: color)),
      ],
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

  Widget _buildActionGrid(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildSmallAction(Icons.remove_circle_outline, 'EXPENSE', AppColors.expense, () => context.push('/add-transaction?type=expense'))),
        const SizedBox(width: 12),
        Expanded(child: _buildSmallAction(Icons.add_circle_outline, 'INCOME', AppColors.income, () => context.push('/add-transaction?type=income'))),
        const SizedBox(width: 12),
        Expanded(child: _buildSmallAction(Icons.swap_horiz_rounded, 'SYNC', AppColors.accent, () {})),
      ],
    );
  }

  Widget _buildSmallAction(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: NeonCard(
        padding: const EdgeInsets.symmetric(vertical: 16),
        glowColor: color,
        opacity: 0.3,
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(label, style: AppTextStyles.labelNeon.copyWith(fontSize: 8, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(dynamic t, dynamic category, NumberFormat currency) {
    final color = Color(category?.color ?? 0xFF9D50BB);
    return NeonCard(
      padding: const EdgeInsets.all(12),
      opacity: 0.2,
      hasGlow: false,
      borderColor: AppColors.surfaceLight,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_getIcon(category?.iconName ?? 'more_horiz'), color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.description, style: AppTextStyles.headlineTitle.copyWith(fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(category?.name ?? 'SYSTEM', style: AppTextStyles.bodyMain.copyWith(fontSize: 10)),
              ],
            ),
          ),
          Text(
            '${t.isIncome ? '+' : '-'}${currency.format(t.amount)}',
            style: AppTextStyles.headlineTitle.copyWith(fontSize: 14, color: t.isIncome ? AppColors.income : AppColors.expense),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const NeonCard(
      child: Center(child: Text('NO DATA STREAMS DETECTED')),
    );
  }

  IconData _getIcon(String name) {
    const iconMap = {
      'restaurant': Icons.restaurant_menu_rounded,
      'directions_car': Icons.directions_car_filled_rounded,
      'shopping_bag': Icons.shopping_bag_rounded,
    };
    return iconMap[name] ?? Icons.grid_view_rounded;
  }
}
