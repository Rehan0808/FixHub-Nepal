import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:fixhub_nepal/features/dashboard/presentation/pages/home_screen.dart';
import 'package:fixhub_nepal/features/notifications/services/notification_service.dart';

void main() {
  group('HomeScreen', () {
    Widget buildSubject() => ChangeNotifierProvider<NotificationService>(
          create: (_) => NotificationService(),
          child: const MaterialApp(home: Scaffold(body: HomeScreen())),
        );

    testWidgets('1. renders HomeScreen widget successfully', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('2. displays Text widgets in the screen', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('3. displays Quick Actions section', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();
      expect(find.text('Quick Actions'), findsOneWidget);
    });
  });
}