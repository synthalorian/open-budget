import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/domain/entities/transaction.dart';
import '../../../core/services/notification_service.dart';
import '../../../shared/providers/database_provider.dart';
import '../../transactions/data/transaction_providers.dart';
import '../../budget/data/budget_providers.dart';
import '../../settings/data/notification_settings_provider.dart';
import '../../goals/data/goal_providers.dart';

// Spending insights
final spendingInsightsProvider = Provider<List<SpendingInsight>>((ref) {
  final transactions = ref.watch(currentMonthTransactionsProvider);
  final expensesByCategory = ref.watch(expensesByCategoryProvider);
  final budgetUsage = ref.watch(budgetUsageProvider);
  final categories = ref.watch(databaseProvider).categories;
  
  final insights = <SpendingInsight>[];
  
  // Check for over-budget categories
  for (final usage in budgetUsage.values) {
    if (usage.isOverBudget) {
      final category = categories.get(usage.budget.categoryId);
      insights.add(SpendingInsight(
        type: InsightType.warning,
        title: 'Over Budget',
        description: 'You\'ve exceeded your ${category?.name ?? 'category'} budget by \$${(usage.spent - usage.budget.amount).toStringAsFixed(2)}',
        icon: 'warning',
        color: 0xFFEF4444,
      ));
    } else if (usage.percentUsed >= 0.9) {
      final category = categories.get(usage.budget.categoryId);
      insights.add(SpendingInsight(
        type: InsightType.caution,
        title: 'Budget Alert',
        description: 'You\'ve used ${(usage.percentUsed * 100).toStringAsFixed(0)}% of your ${category?.name ?? 'category'} budget',
        icon: 'info',
        color: 0xFFF59E0B,
      ));
    }
  }
  
  // Check for high spending patterns
  if (transactions.isNotEmpty) {
    final avgTransaction = transactions
        .where((t) => !t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount) / transactions.where((t) => !t.isIncome).length;
    
    final highTransactions = transactions
        .where((t) => !t.isIncome && t.amount > avgTransaction * 2)
        .toList();
    
    if (highTransactions.isNotEmpty) {
      insights.add(SpendingInsight(
        type: InsightType.info,
        title: 'Large Transactions',
        description: 'You have ${highTransactions.length} transaction(s) above your average spending',
        icon: 'trending_up',
        color: 0xFF3B82F6,
      ));
    }
  }
  
  // Top spending category
  if (expensesByCategory.isNotEmpty) {
    final topCategory = expensesByCategory.entries
        .reduce((a, b) => a.value > b.value ? a : b);
    final category = categories.get(topCategory.key);
    
    insights.add(SpendingInsight(
      type: InsightType.info,
      title: 'Top Spending',
      description: 'Your highest spending category is ${category?.name ?? 'Unknown'} at \$${topCategory.value.toStringAsFixed(2)}',
      icon: 'pie_chart',
      color: 0xFF7C3AED,
    ));
  }

  // Anomaly Detection: Detect transactions 3x higher than category average
  final allTransactions = ref.watch(transactionsProvider);
  if (allTransactions.isNotEmpty) {
    for (final category in categories.values) {
      final catTransactions = allTransactions.where((t) => !t.isIncome && t.categoryId == category.id).toList();
      if (catTransactions.length < 5) continue; 

      final total = catTransactions.fold(0.0, (sum, t) => sum + t.amount);
      final avg = total / catTransactions.length;

      final recentAnomalies = catTransactions
          .where((t) => t.date.isAfter(DateTime.now().subtract(const Duration(days: 7))))
          .where((t) => t.amount > avg * 3)
          .toList();

      for (final anomaly in recentAnomalies) {
        insights.add(SpendingInsight(
          type: InsightType.anomaly,
          title: 'Anomaly Detected',
          description: 'Unusual activity in ${category.name}: \$${anomaly.amount.toStringAsFixed(0)} transaction is 3x your average.',
          icon: 'radar',
          color: 0xFF00F2FE,
        ));
      }
    }
  }
  
  return insights;
});

// Weekly spending trend
final weeklySpendingTrendProvider = Provider<List<WeeklySpending>>((ref) {
  final transactions = ref.watch(transactionsProvider);
  final now = DateTime.now();
  
  final weeks = <WeeklySpending>[];
  
  for (int i = 0; i < 7; i++) {
    final weekStart = now.subtract(Duration(days: (i * 7) + now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    
    final weekTransactions = transactions.where((t) {
      return !t.isIncome && 
             t.date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
             t.date.isBefore(weekEnd.add(const Duration(days: 1)));
    });
    
    final total = weekTransactions.fold(0.0, (sum, t) => sum + t.amount);
    
    weeks.add(WeeklySpending(
      weekStart: weekStart,
      weekEnd: weekEnd,
      total: total,
      transactionCount: weekTransactions.length,
    ));
  }
  
  return weeks;
});

// Category breakdown with percentages
final categoryBreakdownProvider = Provider<List<CategoryBreakdown>>((ref) {
  final expensesByCategory = ref.watch(expensesByCategoryProvider);
  final categories = ref.watch(databaseProvider).categories;
  final totalExpenses = ref.watch(currentMonthExpensesProvider);
  
  final breakdown = <CategoryBreakdown>[];
  
  for (final entry in expensesByCategory.entries) {
    final category = categories.get(entry.key);
    final percentage = totalExpenses > 0 
        ? (entry.value / totalExpenses) * 100.0 
        : 0.0;
    
    breakdown.add(CategoryBreakdown(
      categoryId: entry.key,
      categoryName: category?.name ?? 'Unknown',
      amount: entry.value,
      percentage: percentage,
      color: category?.color ?? 0xFF6B7280,
      icon: category?.iconName ?? 'more_horiz',
    ));
  }
  
  breakdown.sort((a, b) => b.amount.compareTo(a.amount));
  
  return breakdown;
});

// Spending comparison (this month vs last month)
final spendingComparisonProvider = Provider<SpendingComparison?>((ref) {
  final transactions = ref.watch(transactionsProvider);
  final now = DateTime.now();
  
  // This month
  final thisMonthStart = DateTime(now.year, now.month, 1);
  final thisMonthTransactions = transactions.where((t) => 
      !t.isIncome && 
      (t.date.isAfter(thisMonthStart) || t.date.isAtSameMomentAs(thisMonthStart)));
  final thisMonthTotal = thisMonthTransactions.fold(0.0, (sum, t) => sum + t.amount);
  
  // Last month
  final lastMonthStart = DateTime(now.year, now.month - 1, 1);
  final lastMonthEnd = DateTime(now.year, now.month, 0);
  final lastMonthTransactions = transactions.where((t) => 
      !t.isIncome && 
      (t.date.isAfter(lastMonthStart) || t.date.isAtSameMomentAs(lastMonthStart)) &&
      (t.date.isBefore(lastMonthEnd) || t.date.isAtSameMomentAs(lastMonthEnd)));
  final lastMonthTotal = lastMonthTransactions.fold(0.0, (sum, t) => sum + t.amount);
  
  if (lastMonthTotal == 0) return null;
  
  final change = thisMonthTotal - lastMonthTotal;
  final percentChange = (change / lastMonthTotal) * 100;
  
  return SpendingComparison(
    thisMonth: thisMonthTotal,
    lastMonth: lastMonthTotal,
    change: change,
    percentChange: percentChange,
    isIncrease: change > 0,
  );
});

// AI Spending Predictor (Projection for end of month)
final spendingPredictorProvider = Provider<SpendingProjection?>((ref) {
  final transactions = ref.watch(transactionsProvider);
  final budgets = ref.watch(categoryBudgetsProvider);
  final notificationSettings = ref.watch(notificationSettingsProvider);
  final now = DateTime.now();
  
  if (transactions.isEmpty) return null;

  // 1. Calculate current burn rate (average daily spend this month)
  final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
  final currentDay = now.day;
  
  final thisMonthStart = DateTime(now.year, now.month, 1);
  final expensesThisMonth = transactions.where((t) => 
    !t.isIncome && 
    (t.date.isAfter(thisMonthStart) || t.date.isAtSameMomentAs(thisMonthStart))
  ).toList();
  
  if (expensesThisMonth.isEmpty) return null;
  
  final totalSpentSoFar = expensesThisMonth.fold(0.0, (sum, t) => sum + t.amount);
  final avgDailySpend = totalSpentSoFar / currentDay;
  
  // 2. Linear projection
  final predictedTotal = avgDailySpend * daysInMonth;
  
  // 3. Category-specific projections & budget collision detection
  final alerts = <SpendingInsight>[];
  
  final totalBudget = budgets.fold(0.0, (sum, b) => sum + b.amount);
  
  for (final budget in budgets) {
    final catExpenses = expensesThisMonth.where((t) => t.categoryId == budget.categoryId).toList();
    if (catExpenses.isEmpty) continue;
    
    final catSpentSoFar = catExpenses.fold(0.0, (sum, t) => sum + t.amount);
    final catPredicted = (catSpentSoFar / currentDay) * daysInMonth;
    
    if (catPredicted > budget.amount && catSpentSoFar <= budget.amount) {
      final alert = SpendingInsight(
        type: InsightType.warning,
        title: 'Collision Warning',
        description: 'Predictive data suggests you will exceed your ${budget.name} limit by \$${(catPredicted - budget.amount).toStringAsFixed(2)} if current velocity continues.',
        icon: 'bolt',
        color: 0xFFFF0055,
      );
      alerts.add(alert);
      
      // Proactive Smart Notification (only if enabled)
      if (notificationSettings.projectionAlerts) {
        NotificationService().showNotification(
          id: budget.categoryId.hashCode,
          title: '⚠️ Mainframe Alert: ${budget.name}',
          body: 'End-of-month spend projected at \$${catPredicted.toStringAsFixed(0)}. Limit: \$${budget.amount.toStringAsFixed(0)}',
          payload: '/insights',
        );
      }
    }
  }

  // 4. Overall health assessment
  String healthStatus = 'STABLE';
  if (totalBudget > 0) {
    if (predictedTotal > totalBudget) {
      healthStatus = 'CRITICAL';
      
      // System critical notification (only if enabled)
      if (notificationSettings.projectionAlerts) {
        NotificationService().showNotification(
          id: 999,
          title: '🚨 SYSTEM CRITICAL',
          body: 'Total monthly spend is projected to exceed all budget allocations.',
          payload: '/insights',
        );
      }
    } else if (predictedTotal > totalBudget * 0.8) {
      healthStatus = 'WARNING';
    }
  }

  return SpendingProjection(
    currentSpent: totalSpentSoFar,
    predictedTotal: predictedTotal,
    daysRemaining: daysInMonth - currentDay,
    velocity: avgDailySpend,
    healthStatus: healthStatus,
    alerts: alerts,
  );
});

// Savings Optimizer (Actionable suggestions)
final savingsOptimizerProvider = Provider<List<SavingsSuggestion>>((ref) {
  final projection = ref.watch(spendingPredictorProvider);
  final budgets = ref.watch(categoryBudgetsProvider);
  final goals = ref.watch(activeGoalsProvider);
  final budgetUsage = ref.watch(budgetUsageProvider);
  
  if (projection == null || goals.isEmpty) return [];
  
  final suggestions = <SavingsSuggestion>[];
  
  // 1. Identify "Low Velocity" categories (spending less than 50% of projection)
  for (final budget in budgets) {
    final usage = budgetUsage[budget.categoryId];
    if (usage == null) continue;
    
    // If we're more than 10 days into the month and using < 30% of budget
    final now = DateTime.now();
    if (now.day > 10 && usage.percentUsed < 0.3) {
      final potentialSavings = (budget.amount * 0.2).roundToDouble(); // Suggest moving 20%
      
      suggestions.add(SavingsSuggestion(
        title: 'Optimize ${budget.name}',
        description: 'You\'re spending significantly below velocity in ${budget.name}. Reallocating \$${potentialSavings.toStringAsFixed(0)} to your goals could accelerate your targets.',
        actionLabel: 'REALLOCATE',
        impactAmount: potentialSavings,
        type: SuggestionType.reallocate,
        sourceId: budget.id,
        targetId: goals.first.id, 
      ));
    }
  }
  
  // 2. Goal-specific "Boost" suggestions
  for (final goal in goals) {
    if (goal.progress < 0.9 && goal.progress > 0.7) {
      final remaining = goal.targetAmount - goal.currentAmount;
      suggestions.add(SavingsSuggestion(
        title: 'Finish Line Near: ${goal.name}',
        description: 'You are \$${remaining.toStringAsFixed(0)} away from completing this target. A small one-time boost today would close this module.',
        actionLabel: 'BOOST TARGET',
        impactAmount: remaining,
        type: SuggestionType.boost,
        targetId: goal.id,
      ));
    }
  }
  
  return suggestions;
});

// Optimizer Notifier for executing suggestions
final optimizerNotifierProvider = StateNotifierProvider<OptimizerNotifier, AsyncValue<void>>((ref) {
  return OptimizerNotifier(ref);
});

class OptimizerNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  OptimizerNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<void> executeSuggestion(SavingsSuggestion suggestion) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final db = ref.read(databaseProvider);
      
      if (suggestion.type == SuggestionType.reallocate && suggestion.sourceId != null) {
        final budget = db.budgets.get(suggestion.sourceId);
        if (budget != null) {
          final newBudget = budget.copyWith(amount: budget.amount - suggestion.impactAmount);
          await db.budgets.put(budget.id, newBudget);
        }
        
        if (suggestion.targetId != null) {
          final goal = db.goals.get(suggestion.targetId);
          if (goal != null) {
            final newGoal = goal.copyWith(currentAmount: goal.currentAmount + suggestion.impactAmount);
            await db.goals.put(goal.id, newGoal);
          }
        }
      } else if (suggestion.type == SuggestionType.boost && suggestion.targetId != null) {
        final goal = db.goals.get(suggestion.targetId);
        if (goal != null) {
          final newGoal = goal.copyWith(currentAmount: goal.currentAmount + suggestion.impactAmount);
          await db.goals.put(goal.id, newGoal);
        }
      }
      
      ref.invalidate(budgetsProvider);
      ref.invalidate(goalsProvider);
    });
  }
}

// Weekly Digest Generator
final weeklyDigestProvider = Provider<String?>((ref) {
  final now = DateTime.now();
  if (now.weekday != DateTime.sunday) return null;

  final trend = ref.watch(weeklySpendingTrendProvider);
  if (trend.isEmpty) return null;

  final currentWeek = trend.first;
  final lastWeek = trend.length > 1 ? trend[1] : null;

  String digest = 'SUNDAY_STATUS_REPORT:\n';
  digest += 'Total spend this week: \$${currentWeek.total.toStringAsFixed(0)}.\n';
  
  if (lastWeek != null) {
    final diff = currentWeek.total - lastWeek.total;
    if (diff > 0) {
      digest += 'Spending increased by \$${diff.toStringAsFixed(0)} vs last week.\n';
    } else {
      digest += 'Efficiency up! Spent \$${diff.abs().toStringAsFixed(0)} less than last week.\n';
    }
  }

  return digest;
});

// Financial Health Score (0-100)
final healthScoreProvider = Provider<int>((ref) {
  final budgetUsage = ref.watch(totalBudgetUsageProvider);
  final savings = ref.watch(totalSavingsProvider);
  final target = ref.watch(totalTargetProvider);
  final comparison = ref.watch(spendingComparisonProvider);
  
  double score = 70.0; // Base score
  
  // 1. Budget Adherence (max +/- 20)
  if (budgetUsage != null) {
    if (budgetUsage.isOverBudget) {
      score -= 20;
    } else if (budgetUsage.percentUsed < 0.8) {
      score += 10;
    }
  }
  
  // 2. Savings Progress (max +10)
  if (target > 0) {
    final savingsRate = savings / target;
    score += (savingsRate * 10);
  }
  
  // 3. Month-over-Month efficiency (max +/- 10)
  if (comparison != null) {
    if (!comparison.isIncrease) {
      score += 10;
    } else {
      score -= (comparison.percentChange / 10).clamp(0, 10);
    }
  }
  
  return score.clamp(0, 100).toInt();
});

// Data models
enum InsightType { info, caution, warning, success, anomaly }

enum SuggestionType { reallocate, boost, optimize }

class SavingsSuggestion {
  final String title;
  final String description;
  final String actionLabel;
  final double impactAmount;
  final SuggestionType type;
  final String? sourceId;
  final String? targetId;

  const SavingsSuggestion({
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.impactAmount,
    required this.type,
    this.sourceId,
    this.targetId,
  });
}

class SpendingProjection {
  final double currentSpent;
  final double predictedTotal;
  final int daysRemaining;
  final double velocity;
  final String healthStatus;
  final List<SpendingInsight> alerts;

  const SpendingProjection({
    required this.currentSpent,
    required this.predictedTotal,
    required this.daysRemaining,
    required this.velocity,
    required this.healthStatus,
    required this.alerts,
  });
}

class SpendingInsight {
  final InsightType type;
  final String title;
  final String description;
  final String icon;
  final int color;

  const SpendingInsight({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class WeeklySpending {
  final DateTime weekStart;
  final DateTime weekEnd;
  final double total;
  final int transactionCount;

  const WeeklySpending({
    required this.weekStart,
    required this.weekEnd,
    required this.total,
    required this.transactionCount,
  });
}

class CategoryBreakdown {
  final String categoryId;
  final String categoryName;
  final double amount;
  final double percentage;
  final int color;
  final String icon;

  const CategoryBreakdown({
    required this.categoryId,
    required this.categoryName,
    required this.amount,
    required this.percentage,
    required this.color,
    required this.icon,
  });
}

class SpendingComparison {
  final double thisMonth;
  final double lastMonth;
  final double change;
  final double percentChange;
  final bool isIncrease;

  const SpendingComparison({
    required this.thisMonth,
    required this.lastMonth,
    required this.change,
    required this.percentChange,
    required this.isIncrease,
  });
}
