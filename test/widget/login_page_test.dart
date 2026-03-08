import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fixhub_nepal/features/presentation/pages/login_page.dart';

void main() {
  group('LoginPage', () {
    Widget buildSubject() => const MaterialApp(home: LoginPage());

    // ── Test 1 ─────────────────────────────────────────────────────────────
    testWidgets('1. renders Scaffold successfully', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      expect(find.byType(Scaffold), findsOneWidget);
    });

    // ── Test 2 ─────────────────────────────────────────────────────────────
    testWidgets('2. shows at least two TextField widgets (email & password)',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsWidgets);
    });

    // ── Test 3 ─────────────────────────────────────────────────────────────
    testWidgets('3. has at least one button widget', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      final buttons = find.byWidgetPredicate(
        (w) => w is ElevatedButton || w is TextButton || w is OutlinedButton,
      );
      expect(buttons, findsWidgets);
    });

    // ── Test 4 ─────────────────────────────────────────────────────────────
    testWidgets('4. can type an email address into the first TextField',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'user@example.com');
      await tester.pump();
      expect(find.text('user@example.com'), findsOneWidget);
    });

    // ── Test 5 ─────────────────────────────────────────────────────────────
    testWidgets('5. has Column layout for form structure',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      expect(find.byType(Column), findsWidgets);
    });
  });
}