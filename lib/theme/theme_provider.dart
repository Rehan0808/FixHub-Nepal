import 'package:flutter/material.dart';
import 'package:light_sensor/light_sensor.dart';
import 'package:proximity_sensor/proximity_sensor.dart';
import 'dart:async';
import '../core/services/hive_services.dart';

enum AppThemeMode { light, dark, auto, proximity }

class ThemeProvider with ChangeNotifier {
  AppThemeMode _selection = AppThemeMode.light;
  ThemeMode _currentActualMode = ThemeMode.light;
  StreamSubscription? _lightSubscription;
  StreamSubscription? _proximitySubscription;

  ThemeProvider() {
    _loadFromHive();
  }

  AppThemeMode get selection => _selection;
  ThemeMode get themeMode {
    if (_selection == AppThemeMode.auto || _selection == AppThemeMode.proximity) {
      return _currentActualMode;
    }
    return _selection == AppThemeMode.light ? ThemeMode.light : ThemeMode.dark;
  }

  bool get isDarkMode => themeMode == ThemeMode.dark;

  void _loadFromHive() {
    final box = HiveService().profileBox;
    final savedMode = box.get('appThemeMode', defaultValue: 'light');
    _selection = AppThemeMode.values.firstWhere((e) => e.name == savedMode, orElse: () => AppThemeMode.light);
    _updateAutoListener();
    notifyListeners();
  }

  void setThemeMode(AppThemeMode mode) {
    if (_selection == mode) return;
    _selection = mode;
    HiveService().profileBox.put('appThemeMode', mode.name);
    _updateAutoListener();
    notifyListeners();
  }

  void _updateAutoListener() {
    _lightSubscription?.cancel();
    _proximitySubscription?.cancel();

    if (_selection == AppThemeMode.auto) {
      _lightSubscription = LightSensor.luxStream().listen((int lux) {
        // Hysteresis: low lux turns dark, high lux turns light
        if (lux < 20 && _currentActualMode != ThemeMode.dark) {
          _currentActualMode = ThemeMode.dark;
          notifyListeners();
        } else if (lux > 40 && _currentActualMode != ThemeMode.light) {
          _currentActualMode = ThemeMode.light;
          notifyListeners();
        }
      });
    } else if (_selection == AppThemeMode.proximity) {
      try {
        _proximitySubscription = ProximitySensor.events
            .handleError((e) {
              // Sensor unavailable on this device — fall back to light
              debugPrint('PROXIMITY_SENSOR_ERROR: $e');
              _proximitySubscription?.cancel();
              _selection = AppThemeMode.light;
              _currentActualMode = ThemeMode.light;
              notifyListeners();
            })
            .listen(
          (int event) {
            // Only react when hand covers sensor (event == 1)
            // Each cover toggles between dark and light — removing hand does nothing
            if (event == 1) {
              _currentActualMode = _currentActualMode == ThemeMode.dark
                  ? ThemeMode.light
                  : ThemeMode.dark;
              notifyListeners();
            }
          },
        );
      } catch (e) {
        debugPrint('PROXIMITY_SENSOR_INIT_ERROR: $e');
        _selection = AppThemeMode.light;
        _currentActualMode = ThemeMode.light;
        notifyListeners();
      }
    }
  }

  // Legacy support for toggle (optional, can be removed if not used)
  void toggleTheme() {
    if (_selection == AppThemeMode.light) {
      setThemeMode(AppThemeMode.dark);
    } else {
      setThemeMode(AppThemeMode.light);
    }
  }

  @override
  void dispose() {
    _lightSubscription?.cancel();
    _proximitySubscription?.cancel();
    super.dispose();
  }
}
