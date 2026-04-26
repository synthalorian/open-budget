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
    ref.watch(spendingInsightsProvider); // Keep provider active for notifications
    final db = ref.watch(databaseProvider);
    final currencyFormat = NumberFormat.simpleCurrency(decimalDigits: 0);
    final healthScore = ref.watch(healthScoreProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('THE GRID', style: AppTextStyles.headlineMainframe),
        actions: [
          IconButton(
            icon: Icon(Icons.bolt_rounded, color: AppColors.accent),
            tooltip: 'INSIGHTS',
            onPressed: () => context.go('/insights'),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.spaceGradient),
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
                  return _buildTransactionCard(context, ref, t, category, currencyFormat);
                }).toList(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-transaction'),
        backgroundColor: AppColors.accent,
        child: Icon(Icons.add_rounded, color: AppColors.background, size: 32),
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
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
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
        Expanded(child: _buildSmallAction(Icons.swap_horiz_rounded, 'SYNC', AppColors.accent, () => context.push('/cloud-sync'))),
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

  Widget _buildTransactionCard(BuildContext context, WidgetRef ref, dynamic t, dynamic category, NumberFormat currency) {
    final color = Color(category?.color ?? 0xFF9D50BB);
    final accent = t.isIncome ? AppColors.income : AppColors.expense;
    return Dismissible(
      key: ValueKey('tx-${t.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: AppColors.expense.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.expense.withValues(alpha: 0.5)),
        ),
        child: Icon(Icons.delete_forever_rounded, color: AppColors.expense),
      ),
      confirmDismiss: (_) => _confirmDelete(context, t, accent),
      onDismissed: (_) {
        ref.read(transactionNotifierProvider.notifier).deleteTransaction(t.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${t.isIncome ? "INFLOW" : "OUTFLOW"} PURGED', style: AppTextStyles.labelNeon.copyWith(color: accent)),
            backgroundColor: AppColors.surface,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: GestureDetector(
        onLongPress: () async {
          final ok = await _confirmDelete(context, t, accent) ?? false;
          if (ok) {
            ref.read(transactionNotifierProvider.notifier).deleteTransaction(t.id);
          }
        },
        child: NeonCard(
          padding: const EdgeInsets.all(12),
          opacity: 0.2,
          hasGlow: false,
          borderColor: AppColors.surfaceLight,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_getIcon(category?.iconName ?? 'more_horiz'), color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.description.toString().isEmpty ? '(no description)' : t.description,
                      style: AppTextStyles.headlineTitle.copyWith(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(category?.name ?? 'SYSTEM', style: AppTextStyles.bodyMain.copyWith(fontSize: 10)),
                  ],
                ),
              ),
              Text(
                '${t.isIncome ? '+' : '-'}${currency.format(t.amount)}',
                style: AppTextStyles.headlineTitle.copyWith(fontSize: 14, color: accent),
              ),
              const SizedBox(width: 8),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                icon: Icon(Icons.delete_outline_rounded, color: AppColors.textMuted, size: 18),
                tooltip: 'PURGE',
                onPressed: () async {
                  final ok = await _confirmDelete(context, t, accent) ?? false;
                  if (ok) {
                    ref.read(transactionNotifierProvider.notifier).deleteTransaction(t.id);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context, dynamic t, Color accent) {
    final label = t.isIncome ? 'INFLOW' : 'OUTFLOW';
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('PURGE $label?', style: AppTextStyles.labelNeon.copyWith(color: accent)),
        content: Text(
          'Removing "${t.description.toString().isEmpty ? "(no description)" : t.description}" cannot be undone.',
          style: AppTextStyles.bodyMain.copyWith(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('CANCEL', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('PURGE', style: TextStyle(color: AppColors.expense)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return NeonCard(
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
