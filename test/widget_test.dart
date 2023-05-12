import 'package:flutter_test/flutter_test.dart';
import 'package:green_bush/app.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('Dashboard'), findsOneWidget);
  });
}
