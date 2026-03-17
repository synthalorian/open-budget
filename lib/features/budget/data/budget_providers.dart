import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/domain/entities/budget.dart';
import '../../../shared/providers/database_provider.dart';
import '../../transactions/data/transaction_providers.dart';

// All budgets
final budgetsProvider = Provider<List<Budget>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.budgets.values.where((b) => b.isActive).toList();
});

// Category budgets only
final categoryBudgetsProvider = Provider<List<Budget>>((ref) {
  final budgets = ref.watch(budgetsProvider);
  return budgets.where((b) => b.type == BudgetType.category).toList();
});

// Total budget for current period
final totalBudgetProvider = Provider<Budget?>((ref) {
  final budgets = ref.watch(budgetsProvider);
  try {
    return budgets.firstWhere((b) => b.type == BudgetType.total);
  } catch (_) {
    return null;
  }
});

// Budget usage by category
final budgetUsageProvider = Provider<Map<String, BudgetUsage>>((ref) {
  final budgets = ref.watch(categoryBudgetsProvider);
  final expensesByCategory = ref.watch(expensesByCategoryProvider);
  
  final Map<String, BudgetUsage> result = {};
  
  for (final budget in budgets) {
    if (budget.categoryId != null) {
      final spent = expensesByCategory[budget.categoryId] ?? 0.0;
      final remaining = budget.amount - spent;
      final percentUsed = budget.amount > 0 ? (spent / budget.amount).clamp(0.0, 1.0) : 0.0;
      
      result[budget.categoryId!] = BudgetUsage(
        budget: budget,
        spent: spent,
        remaining: remaining,
        percentUsed: percentUsed,
        isOverBudget: spent > budget.amount,
      );
    }
  }
  
  return result;
});

// Total budget usage
final totalBudgetUsageProvider = Provider<BudgetUsage?>((ref) {
  final totalBudget = ref.watch(totalBudgetProvider);
  final totalExpenses = ref.watch(currentMonthExpensesProvider);
  
  if (totalBudget == null) return null;
  
  final remaining = totalBudget.amount - totalExpenses;
  final percentUsed = totalBudget.amount > 0 
      ? (totalExpenses / totalBudget.amount).clamp(0.0, 1.0) 
      : 0.0;
  
  return BudgetUsage(
    budget: totalBudget,
    spent: totalExpenses,
    remaining: remaining,
    percentUsed: percentUsed,
    isOverBudget: totalExpenses > totalBudget.amount,
  );
});

// Budget notifier for CRUD operations
final budgetNotifierProvider =
    StateNotifierProvider<BudgetNotifier, AsyncValue<void>>((ref) {
  return BudgetNotifier(ref);
});

class BudgetUsage {
  final Budget budget;
  final double spent;
  final double remaining;
  final double percentUsed;
  final bool isOverBudget;

  const BudgetUsage({
    required this.budget,
    required this.spent,
    required this.remaining,
    required this.percentUsed,
    required this.isOverBudget,
  });
}

class BudgetNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  BudgetNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<void> createBudget(Budget budget) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final db = ref.read(databaseProvider);
      await db.budgets.put(budget.id, budget);
      ref.invalidate(budgetsProvider);
    });
  }

  Future<void> updateBudget(Budget budget) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final db = ref.read(databaseProvider);
      await db.budgets.put(budget.id, budget);
      ref.invalidate(budgetsProvider);
    });
  }

  Future<void> deleteBudget(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final db = ref.read(databaseProvider);
      await db.budgets.delete(id);
      ref.invalidate(budgetsProvider);
    });
  }
}
