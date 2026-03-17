import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 1)
enum CategoryType {
  @HiveField(0)
  expense,
  @HiveField(1)
  income,
  @HiveField(2)
  both,
}

@HiveType(typeId: 2)
class Category extends Equatable {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String iconName;
  
  @HiveField(3)
  final int color;
  
  @HiveField(4)
  final CategoryType type;
  
  @HiveField(5)
  final double budgetLimit;
  
  @HiveField(6)
  final bool isSystem;
  
  @HiveField(7)
  final int sortOrder;
  
  @HiveField(8)
  final String? parentId;

  const Category({
    required this.id,
    required this.name,
    required this.iconName,
    required this.color,
    this.type = CategoryType.expense,
    this.budgetLimit = 0,
    this.isSystem = false,
    this.sortOrder = 0,
    this.parentId,
  });

  Category copyWith({
    String? id,
    String? name,
    String? iconName,
    int? color,
    CategoryType? type,
    double? budgetLimit,
    bool? isSystem,
    int? sortOrder,
    String? parentId,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      color: color ?? this.color,
      type: type ?? this.type,
      budgetLimit: budgetLimit ?? this.budgetLimit,
      isSystem: isSystem ?? this.isSystem,
      sortOrder: sortOrder ?? this.sortOrder,
      parentId: parentId ?? this.parentId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        iconName,
        color,
        type,
        budgetLimit,
        isSystem,
        sortOrder,
        parentId,
      ];
}
