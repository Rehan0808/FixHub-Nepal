import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fixhub_nepal/features/onboarding/presentation/pages/on_boarding1.dart';

void main() {
  group('OnboardingPage', () {
    Widget buildSubject() => const MaterialApp(home: Onboarding1());

    testWidgets('1. renders Onboarding1 widget successfully', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      expect(find.byType(Onboarding1), findsOneWidget);
    });

    testWidgets('2. has Scaffold widget', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('3. displays descriptive Text widgets', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('4. has at least one navigation button', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      final buttons = find.byWidgetPredicate(
        (w) => w is ElevatedButton || w is TextButton || w is OutlinedButton,
      );
      expect(buttons, findsWidgets);
    });
  });
}