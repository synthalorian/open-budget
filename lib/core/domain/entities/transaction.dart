import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 0)
class Transaction extends Equatable {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final double amount;
  
  @HiveField(2)
  final String categoryId;
  
  @HiveField(3)
  final String description;
  
  @HiveField(4)
  final DateTime date;
  
  @HiveField(5)
  final bool isIncome;
  
  @HiveField(6)
  final List<String> tags;
  
  @HiveField(7)
  final String? merchantName;
  
  @HiveField(8)
  final bool isRecurring;
  
  @HiveField(9)
  final String? recurringId;
  
  @HiveField(10)
  final DateTime createdAt;
  
  @HiveField(11)
  final DateTime? updatedAt;

  const Transaction({
    required this.id,
    required this.amount,
    required this.categoryId,
    required this.description,
    required this.date,
    required this.isIncome,
    this.tags = const [],
    this.merchantName,
    this.isRecurring = false,
    this.recurringId,
    required this.createdAt,
    this.updatedAt,
  });

  Transaction copyWith({
    String? id,
    double? amount,
    String? categoryId,
    String? description,
    DateTime? date,
    bool? isIncome,
    List<String>? tags,
    String? merchantName,
    bool? isRecurring,
    String? recurringId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      date: date ?? this.date,
      isIncome: isIncome ?? this.isIncome,
      tags: tags ?? this.tags,
      merchantName: merchantName ?? this.merchantName,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringId: recurringId ?? this.recurringId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        amount,
        categoryId,
        description,
        date,
        isIncome,
        tags,
        merchantName,
        isRecurring,
        recurringId,
        createdAt,
        updatedAt,
      ];
}
