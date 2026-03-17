import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/domain/entities/transaction.dart';
import '../../../shared/providers/database_provider.dart';

// All transactions
final transactionsProvider = Provider<List<Transaction>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.transactions.values.toList()
    ..sort((a, b) => b.date.compareTo(a.date));
});

// Transactions for current month
final currentMonthTransactionsProvider = Provider<List<Transaction>>((ref) {
  final transactions = ref.watch(transactionsProvider);
  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);
  
  return transactions.where((t) => t.date.isAfter(startOfMonth) || t.date.isAtSameMomentAs(startOfMonth)).toList();
});

// Income for current month
final currentMonthIncomeProvider = Provider<double>((ref) {
  final transactions = ref.watch(currentMonthTransactionsProvider);
  return transactions
      .where((t) => t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);
});

// Expenses for current month
final currentMonthExpensesProvider = Provider<double>((ref) {
  final transactions = ref.watch(currentMonthTransactionsProvider);
  return transactions
      .where((t) => !t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);
});

// Balance (income - expenses)
final balanceProvider = Provider<double>((ref) {
  final income = ref.watch(currentMonthIncomeProvider);
  final expenses = ref.watch(currentMonthExpensesProvider);
  return income - expenses;
});

// Transactions by category for current month
final expensesByCategoryProvider = Provider<Map<String, double>>((ref) {
  final transactions = ref.watch(currentMonthTransactionsProvider);
  final expenses = transactions.where((t) => !t.isIncome);
  
  final Map<String, double> result = {};
  for (final t in expenses) {
    result[t.categoryId] = (result[t.categoryId] ?? 0) + t.amount;
  }
  return result;
});

// Notifier for adding transactions
final transactionNotifierProvider =
    StateNotifierProvider<TransactionNotifier, AsyncValue<void>>((ref) {
  return TransactionNotifier(ref);
});

class TransactionNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  TransactionNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<void> addTransaction(Transaction transaction) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final db = ref.read(databaseProvider);
      await db.transactions.put(transaction.id, transaction);
      ref.invalidate(transactionsProvider);
    });
  }

  Future<void> updateTransaction(Transaction transaction) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final db = ref.read(databaseProvider);
      await db.transactions.put(transaction.id, transaction);
      ref.invalidate(transactionsProvider);
    });
  }

  Future<void> deleteTransaction(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final db = ref.read(databaseProvider);
      await db.transactions.delete(id);
      ref.invalidate(transactionsProvider);
    });
  }
}
