import 'package:flutter_test/flutter_test.dart';
import 'package:open_budget/core/domain/entities/goal.dart';

void main() {
  group('Goal', () {
    test('progress is 0 when no savings', () {
      final g = Goal(
        id: 'g1',
        name: 'Emergency Fund',
        targetAmount: 10000,
        iconName: 'savings',
        color: 0xFF00F5FF,
        createdAt: DateTime(2026, 1, 1),
      );
      expect(g.progress, 0.0);
      expect(g.remaining, 10000);
    });

    test('progress is calculated correctly', () {
      final g = Goal(
        id: 'g2',
        name: 'Car',
        targetAmount: 5000,
        currentAmount: 2500,
        iconName: 'car',
        color: 0xFF9D50BB,
        createdAt: DateTime(2026, 1, 1),
      );
      expect(g.progress, 0.5);
      expect(g.remaining, 2500);
    });

    test('progress clamps at 1.0', () {
      final g = Goal(
        id: 'g3',
        name: 'Overfunded',
        targetAmount: 100,
        currentAmount: 150,
        iconName: 'star',
        color: 0xFF00FFB2,
        createdAt: DateTime(2026, 1, 1),
      );
      expect(g.progress, 1.0);
    });

    test('daysRemaining with target date', () {
      final g = Goal(
        id: 'g4',
        name: 'Future',
        targetAmount: 1000,
        targetDate: DateTime.now().add(const Duration(days: 30)),
        iconName: 'timer',
        color: 0xFFFF0055,
        createdAt: DateTime(2026, 1, 1),
      );
      expect(g.daysRemaining, isNotNull);
      expect(g.daysRemaining, closeTo(30, 1));
    });

    test('daysRemaining null without target date', () {
      final g = Goal(
        id: 'g5',
        name: 'No deadline',
        targetAmount: 1000,
        iconName: 'star',
        color: 0xFF00FFB2,
        createdAt: DateTime(2026, 1, 1),
      );
      expect(g.daysRemaining, isNull);
    });

    test('JSON round-trip', () {
      final g = Goal(
        id: 'g6',
        name: 'Test',
        targetAmount: 500,
        currentAmount: 200,
        iconName: 'flag',
        color: 0xFF9D50BB,
        createdAt: DateTime(2026, 3, 1),
        notes: 'Test note',
      );
      final json = g.toJson();
      final restored = Goal.fromJson(json);
      expect(restored.name, 'Test');
      expect(restored.targetAmount, 500);
      expect(restored.currentAmount, 200);
      expect(restored.notes, 'Test note');
    });
  });
}
