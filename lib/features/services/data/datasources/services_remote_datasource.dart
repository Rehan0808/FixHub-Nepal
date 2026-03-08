import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/services/hive_services.dart';
import '../models/service_model.dart';

class ServicesRemoteDataSource {
  final http.Client client;

  ServicesRemoteDataSource({http.Client? client})
    : client = client ?? http.Client();

  Future<List<ServiceModel>> getServices() async {
    try {
      // Get auth token from Hive profile box
      final Box profileBox = HiveService().profileBox;
      final String? token = profileBox.get('authToken');

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await client.get(
        Uri.parse(ApiEndpoints.services),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        // Backend returns: { success: true, data: [...] }
        final List<dynamic> servicesJson =
            jsonResponse['data'] ?? jsonResponse['services'] ?? [];

        return servicesJson.map((json) => ServiceModel.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else {
        throw Exception('Failed to load services: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching services: $e');
    }
  }

  Future<ServiceModel> getServiceById(String id) async {
    try {
      final Box profileBox = HiveService().profileBox;
      final String? token = profileBox.get('authToken');

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await client.get(
        Uri.parse(ApiEndpoints.serviceById(id)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final Map<String, dynamic> serviceJson =
            jsonResponse['data'] ?? jsonResponse['service'];

        return ServiceModel.fromJson(serviceJson);
      } else {
        throw Exception('Failed to load service: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching service: $e');
    }
  }
}
