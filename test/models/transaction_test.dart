import 'package:flutter_test/flutter_test.dart';
import 'package:open_budget/core/domain/entities/transaction.dart';

void main() {
  group('Transaction', () {
    test('creates expense transaction', () {
      final t = Transaction(
        id: 'test-1',
        amount: 25.50,
        categoryId: 'food',
        description: 'Lunch',
        date: DateTime(2026, 4, 1),
        isIncome: false,
        createdAt: DateTime(2026, 4, 1),
      );
      expect(t.amount, 25.50);
      expect(t.isIncome, false);
      expect(t.description, 'Lunch');
    });

    test('creates income transaction', () {
      final t = Transaction(
        id: 'test-2',
        amount: 3000.0,
        categoryId: 'salary',
        description: 'Paycheck',
        date: DateTime(2026, 4, 1),
        isIncome: true,
        createdAt: DateTime(2026, 4, 1),
      );
      expect(t.isIncome, true);
    });

    test('JSON round-trip', () {
      final t = Transaction(
        id: 'test-3',
        amount: 99.99,
        categoryId: 'food',
        description: 'Dinner',
        date: DateTime(2026, 4, 2),
        isIncome: false,
        createdAt: DateTime(2026, 4, 2),
      );
      final json = t.toJson();
      final restored = Transaction.fromJson(json);
      expect(restored.id, t.id);
      expect(restored.amount, t.amount);
      expect(restored.description, t.description);
    });

    test('copyWith preserves unchanged fields', () {
      final t = Transaction(
        id: 'test-4',
        amount: 50.0,
        categoryId: 'food',
        description: 'Original',
        date: DateTime(2026, 4, 1),
        isIncome: false,
        createdAt: DateTime(2026, 4, 1),
      );
      final updated = t.copyWith(description: 'Updated');
      expect(updated.description, 'Updated');
      expect(updated.amount, 50.0);
      expect(updated.id, 'test-4');
    });
  });
}
