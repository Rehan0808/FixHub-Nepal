import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/services/hive_services.dart';
import '../models/notification_model.dart';

class NotificationRemoteDataSource {
  final HiveService _hiveService = HiveService();
  String? get _token => _hiveService.profileBox.get('authToken');

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      };

  Future<List<NotificationModel>> getNotifications() async {
    final response = await http
        .get(Uri.parse(ApiEndpoints.notifications), headers: _headers)
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> data = json['data'] ?? [];
      return data.map((e) => NotificationModel.fromJson(e)).toList();
    }
    throw Exception('Failed to fetch notifications: ${response.statusCode}');
  }

  Future<void> markRead(String id) async {
    await http
        .put(Uri.parse(ApiEndpoints.notificationMarkRead(id)), headers: _headers)
        .timeout(const Duration(seconds: 10));
  }

  Future<void> markAllRead() async {
    await http
        .put(Uri.parse(ApiEndpoints.notificationsMarkAllRead), headers: _headers)
        .timeout(const Duration(seconds: 10));
  }
}
