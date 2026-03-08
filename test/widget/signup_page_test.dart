import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fixhub_nepal/features/presentation/pages/signup_page.dart';

void main() {
  group('SignupPage', () {
    Widget buildSubject() => const MaterialApp(home: SignupPage());

    // ── Test 1 ────────────────────────────────────────────────────────────
    testWidgets('1. renders Scaffold successfully', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      expect(find.byType(Scaffold), findsOneWidget);
    });

    // ── Test 2 ────────────────────────────────────────────────────────────
    testWidgets('2. shows multiple TextField widgets for form inputs',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsWidgets);
    });

    // ── Test 3 ────────────────────────────────────────────────────────────
    testWidgets('3. has at least one button widget', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      final buttons = find.byWidgetPredicate(
        (w) => w is ElevatedButton || w is TextButton || w is OutlinedButton,
      );
      expect(buttons, findsWidgets);
    });

    // ── Test 4 ────────────────────────────────────────────────────────────
    testWidgets('4. can enter text into the first TextField', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'John Doe');
      await tester.pump();
      expect(find.text('John Doe'), findsOneWidget);
    });
  });
}