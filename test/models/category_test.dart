import 'package:flutter_test/flutter_test.dart';
import 'package:open_budget/core/domain/entities/category.dart';

void main() {
  group('Category', () {
    test('creates with required fields', () {
      final c = Category(
        id: 'test',
        name: 'Food',
        iconName: 'restaurant',
        color: 0xFF9D50BB,
        type: CategoryType.expense,
      );
      expect(c.name, 'Food');
      expect(c.type, CategoryType.expense);
      expect(c.isSystem, false);
    });

    test('system category flag', () {
      final c = Category(
        id: 'sys',
        name: 'System',
        iconName: 'settings',
        color: 0xFF000000,
        type: CategoryType.expense,
        isSystem: true,
      );
      expect(c.isSystem, true);
    });

    test('copyWith works', () {
      final c = Category(
        id: 'test',
        name: 'Original',
        iconName: 'restaurant',
        color: 0xFF9D50BB,
        type: CategoryType.expense,
      );
      final updated = c.copyWith(name: 'Updated');
      expect(updated.name, 'Updated');
      expect(updated.id, 'test');
      expect(updated.type, CategoryType.expense);
    });

    test('CategoryType enum has 3 values', () {
      expect(CategoryType.values.length, 3);
      expect(CategoryType.values, contains(CategoryType.expense));
      expect(CategoryType.values, contains(CategoryType.income));
      expect(CategoryType.values, contains(CategoryType.both));
    });
  });
}
