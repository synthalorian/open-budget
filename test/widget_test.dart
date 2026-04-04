// This is a basic Flutter widget test.

import 'package:flutter_test/flutter_test.dart';
import 'package:open_budget/main.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const OpenBudgetApp());

    // Verify the app title is present
    expect(find.text('Open Budget'), findsOneWidget);
  });
}
