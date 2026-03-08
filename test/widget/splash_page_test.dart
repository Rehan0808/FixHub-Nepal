import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fixhub_nepal/features/splash/splash_page.dart';

void main() {
  group('SplashPage', () {
    testWidgets('1. renders SplashPage widget successfully', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SplashPage()));
      expect(find.byType(SplashPage), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });

    testWidgets('2. has Scaffold widget', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SplashPage()));
      expect(find.byType(Scaffold), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });

    testWidgets('3. displays Text widgets for branding', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SplashPage()));
      await tester.pump();
      expect(find.byType(Text), findsWidgets);
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });

    testWidgets('4. splash remains visible for at least 1 second', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SplashPage()));
      expect(find.byType(SplashPage), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(SplashPage), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });
  });
}