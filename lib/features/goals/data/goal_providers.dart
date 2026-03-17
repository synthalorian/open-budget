import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/domain/entities/goal.dart';
import '../../../shared/providers/database_provider.dart';

// All goals
final goalsProvider = Provider<List<Goal>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.goals.values.toList()
    ..sort((a, b) {
      // Completed goals go to the end
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      // Sort by creation date (newest first)
      return b.createdAt.compareTo(a.createdAt);
    });
});

// Active goals (not completed)
final activeGoalsProvider = Provider<List<Goal>>((ref) {
  final goals = ref.watch(goalsProvider);
  return goals.where((g) => !g.isCompleted).toList();
});

// Completed goals
final completedGoalsProvider = Provider<List<Goal>>((ref) {
  final goals = ref.watch(goalsProvider);
  return goals.where((g) => g.isCompleted).toList();
});

// Total savings across all goals
final totalSavingsProvider = Provider<double>((ref) {
  final goals = ref.watch(activeGoalsProvider);
  return goals.fold(0.0, (sum, g) => sum + g.currentAmount);
});

// Total target across all goals
final totalTargetProvider = Provider<double>((ref) {
  final goals = ref.watch(activeGoalsProvider);
  return goals.fold(0.0, (sum, g) => sum + g.targetAmount);
});

// Goals with progress
final goalsWithProgressProvider = Provider<List<GoalProgress>>((ref) {
  final goals = ref.watch(activeGoalsProvider);
  return goals.map((goal) {
    final percentComplete = goal.progress * 100;
    final remaining = goal.remaining;
    final daysLeft = goal.daysRemaining;
    final monthlyTarget = goal.monthlyTarget;
    
    return GoalProgress(
      goal: goal,
      percentComplete: percentComplete,
      remaining: remaining,
      daysLeft: daysLeft,
      monthlyTarget: monthlyTarget,
      isOnTrack: _isOnTrack(goal),
    );
  }).toList();
});

bool _isOnTrack(Goal goal) {
  if (goal.targetDate == null) return true;
  
  final now = DateTime.now();
  final totalDays = goal.targetDate!.difference(goal.createdAt).inDays;
  final daysPassed = now.difference(goal.createdAt).inDays;
  
  if (totalDays <= 0) return true;
  
  final expectedProgress = daysPassed / totalDays;
  return goal.progress >= expectedProgress;
}

// Goal notifier for CRUD operations
final goalNotifierProvider =
    StateNotifierProvider<GoalNotifier, AsyncValue<void>>((ref) {
  return GoalNotifier(ref);
});

class GoalProgress {
  final Goal goal;
  final double percentComplete;
  final double remaining;
  final int? daysLeft;
  final double? monthlyTarget;
  final bool isOnTrack;

  const GoalProgress({
    required this.goal,
    required this.percentComplete,
    required this.remaining,
    required this.daysLeft,
    required this.monthlyTarget,
    required this.isOnTrack,
  });
}

class GoalNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  GoalNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<void> createGoal(Goal goal) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final db = ref.read(databaseProvider);
      await db.goals.put(goal.id, goal);
      ref.invalidate(goalsProvider);
    });
  }

  Future<void> addToGoal(String goalId, double amount) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final db = ref.read(databaseProvider);
      final goal = db.goals.get(goalId);
      if (goal != null) {
        final newAmount = goal.currentAmount + amount;
        final updatedGoal = goal.copyWith(
          currentAmount: newAmount,
          isCompleted: newAmount >= goal.targetAmount,
          completedAt: newAmount >= goal.targetAmount ? DateTime.now() : null,
        );
        await db.goals.put(goalId, updatedGoal);
        ref.invalidate(goalsProvider);
      }
    });
  }

  Future<void> updateGoal(Goal goal) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final db = ref.read(databaseProvider);
      await db.goals.put(goal.id, goal);
      ref.invalidate(goalsProvider);
    });
  }

  Future<void> deleteGoal(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final db = ref.read(databaseProvider);
      await db.goals.delete(id);
      ref.invalidate(goalsProvider);
    });
  }
}
