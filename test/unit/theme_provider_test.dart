import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:fixhub_nepal/theme/theme_provider.dart';
import 'package:fixhub_nepal/core/services/hive_services.dart';

void main() {
  late Directory _tmpDir;

  setUpAll(() async {
    _tmpDir = await Directory.systemTemp.createTemp('hive_theme_test_');
    await HiveService().initForTest(_tmpDir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    await _tmpDir.delete(recursive: true);
  });

  // Start every test with a clean profile box so the ThemeProvider
  // always reads the default value ('light').
  setUp(() async {
    await HiveService().profileBox.clear();
  });

  // ── Group 1: Initial state ─────────────────────────────────────────────
  group('ThemeProvider — initial state', () {
    test('1. selection is AppThemeMode.light when Hive has no saved value', () {
      final tp = ThemeProvider();
      expect(tp.selection, AppThemeMode.light);
      tp.dispose();
    });

    test('2. themeMode returns ThemeMode.light by default', () {
      final tp = ThemeProvider();
      expect(tp.themeMode, ThemeMode.light);
      tp.dispose();
    });

    test('3. isDarkMode is false by default', () {
      final tp = ThemeProvider();
      expect(tp.isDarkMode, isFalse);
      tp.dispose();
    });
  });

  // ── Group 2: Mode changes ──────────────────────────────────────────────
  group('ThemeProvider — mode changes', () {
    test('4. setThemeMode(dark) updates selection to AppThemeMode.dark', () {
      final tp = ThemeProvider();
      tp.setThemeMode(AppThemeMode.dark);
      expect(tp.selection, AppThemeMode.dark);
      tp.dispose();
    });

    test('5. setThemeMode(dark) makes themeMode return ThemeMode.dark', () {
      final tp = ThemeProvider();
      tp.setThemeMode(AppThemeMode.dark);
      expect(tp.themeMode, ThemeMode.dark);
      tp.dispose();
    });

    test('6. setThemeMode(light) after dark reverts themeMode to ThemeMode.light',
        () {
      final tp = ThemeProvider();
      tp.setThemeMode(AppThemeMode.dark);
      tp.setThemeMode(AppThemeMode.light);
      expect(tp.themeMode, ThemeMode.light);
      tp.dispose();
    });

    test('7. isDarkMode is true after setting AppThemeMode.dark', () {
      final tp = ThemeProvider();
      tp.setThemeMode(AppThemeMode.dark);
      expect(tp.isDarkMode, isTrue);
      tp.dispose();
    });

    test('8. setThemeMode with the same mode does not call notifyListeners', () {
      final tp = ThemeProvider();
      int notifyCount = 0;
      tp.addListener(() => notifyCount++);
      // Already light — calling setThemeMode(light) is a no-op
      tp.setThemeMode(AppThemeMode.light);
      expect(notifyCount, 0);
      tp.dispose();
    });
  });

  // ── Group 3: Toggle helper ─────────────────────────────────────────────
  group('ThemeProvider — toggleTheme', () {
    test('9. toggleTheme() switches from light to dark', () {
      final tp = ThemeProvider();
      tp.toggleTheme();
      expect(tp.themeMode, ThemeMode.dark);
      tp.dispose();
    });

    test('10. toggleTheme() switches from dark back to light', () {
      final tp = ThemeProvider();
      tp.setThemeMode(AppThemeMode.dark);
      tp.toggleTheme();
      expect(tp.themeMode, ThemeMode.light);
      tp.dispose();
    });
  });
}
