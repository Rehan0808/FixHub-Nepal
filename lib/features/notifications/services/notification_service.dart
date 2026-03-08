import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../data/datasources/notification_remote_datasource.dart';
import '../data/models/notification_model.dart';

class NotificationService extends ChangeNotifier {
  final NotificationRemoteDataSource _datasource = NotificationRemoteDataSource();
  final FlutterLocalNotificationsPlugin _localPlugin = FlutterLocalNotificationsPlugin();

  List<NotificationModel> _notifications = [];
  Set<String> _shownIds = {}; // avoid showing banners twice
  Timer? _pollingTimer;
  bool _initialized = false;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.read).length;

  /// Call once after user logs in.
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    // Init local notifications plugin
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _localPlugin.initialize(initSettings);

    await _fetchAndUpdate();
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _fetchAndUpdate();
    });
  }

  Future<void> _fetchAndUpdate() async {
    try {
      final fetched = await _datasource.getNotifications();

      // Find newly arrived unread notifications and show native banners.
      for (final n in fetched) {
        if (!n.read && !_shownIds.contains(n.id)) {
          _shownIds.add(n.id);
          _showLocalBanner(n);
        }
      }

      _notifications = fetched;
      notifyListeners();
    } catch (_) {
      // Silently ignore — don't interrupt the user if network is slow
    }
  }

  Future<void> _showLocalBanner(NotificationModel n) async {
    const androidDetails = AndroidNotificationDetails(
      'fixhub_bookings',
      'Booking Updates',
      channelDescription: 'Notifications about your booking status',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _localPlugin.show(
      n.id.hashCode,
      'FixHub Nepal',
      n.message,
      details,
    );
  }

  Future<void> refresh() => _fetchAndUpdate();

  Future<void> markRead(String id) async {
    try {
      await _datasource.markRead(id);
      _notifications = _notifications.map((n) => n.id == id ? n.copyWith(read: true) : n).toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> markAllRead() async {
    try {
      await _datasource.markAllRead();
      _notifications = _notifications.map((n) => n.copyWith(read: true)).toList();
      notifyListeners();
    } catch (_) {}
  }

  /// Call on logout.
  void stop() {
    _pollingTimer?.cancel();
    _initialized = false;
    _notifications = [];
    _shownIds = {};
    notifyListeners();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}
