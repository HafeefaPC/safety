// This is a basic Flutter widget test for Safe Haven app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:safe_haven/main.dart';

void main() {
  testWidgets('Safe Haven app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SafeHavenApp());

    // Verify that the app title is displayed.
    expect(find.text('Safe Haven'), findsOneWidget);

    // Verify that emergency action buttons are present.
    expect(find.text('Send Location'), findsOneWidget);
    expect(find.text("I'm Safe"), findsOneWidget);
    expect(find.text('Play Siren'), findsOneWidget);
  });
}
