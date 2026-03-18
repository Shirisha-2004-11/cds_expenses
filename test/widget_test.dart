import 'package:flutter_test/flutter_test.dart';
import 'package:cds_expenses/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build the app and trigger a frame
    await tester.pumpWidget(const CDSExpensesApp());

    // Verify the welcome screen loads
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Sign up'), findsOneWidget);
  });
}