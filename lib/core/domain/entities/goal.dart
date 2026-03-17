import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'goal.g.dart';

@HiveType(typeId: 6)
class Goal extends Equatable {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final double targetAmount;
  
  @HiveField(3)
  final double currentAmount;
  
  @HiveField(4)
  final DateTime? targetDate;
  
  @HiveField(5)
  final String iconName;
  
  @HiveField(6)
  final int color;
  
  @HiveField(7)
  final bool isCompleted;
  
  @HiveField(8)
  final DateTime createdAt;
  
  @HiveField(9)
  final DateTime? completedAt;
  
  @HiveField(10)
  final String? notes;

  const Goal({
    required this.id,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0,
    this.targetDate,
    required this.iconName,
    required this.color,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
    this.notes,
  });

  double get progress => targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0;
  
  double get remaining => targetAmount - currentAmount;
  
  int? get daysRemaining {
    if (targetDate == null) return null;
    final now = DateTime.now();
    return targetDate!.difference(now).inDays;
  }
  
  double? get monthlyTarget {
    if (targetDate == null || daysRemaining == null || daysRemaining! <= 0) return null;
    final monthsRemaining = daysRemaining! / 30.0;
    return remaining / monthsRemaining;
  }

  Goal copyWith({
    String? id,
    String? name,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
    String? iconName,
    int? color,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
    String? notes,
  }) {
    return Goal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
      iconName: iconName ?? this.iconName,
      color: color ?? this.color,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        targetAmount,
        currentAmount,
        targetDate,
        iconName,
        color,
        isCompleted,
        createdAt,
        completedAt,
        notes,
      ];
}
