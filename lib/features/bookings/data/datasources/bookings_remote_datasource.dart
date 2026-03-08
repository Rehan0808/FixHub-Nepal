import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/services/hive_services.dart';
import '../models/booking_model.dart';

class BookingsRemoteDataSource {
  final http.Client client;

  BookingsRemoteDataSource({http.Client? client})
    : client = client ?? http.Client();

  /// Get all user bookings
  Future<List<BookingModel>> getUserBookings({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    try {
      final Box profileBox = HiveService().profileBox;
      final String? token = profileBox.get('authToken');

      if (token == null) {
        throw Exception('No authentication token found');
      }

      String url = '${ApiEndpoints.bookings}?page=$page&limit=$limit';
      if (status != null && status != 'All') {
        url += '&status=$status';
      }

      final response = await client.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> bookingsJson = jsonResponse['data'] ?? [];

        return bookingsJson.map((json) => BookingModel.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else {
        throw Exception('Failed to load bookings: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching bookings: $e');
    }
  }

  /// Get pending (unpaid) bookings
  Future<List<BookingModel>> getPendingBookings() async {
    try {
      final Box profileBox = HiveService().profileBox;
      final String? token = profileBox.get('authToken');

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await client.get(
        Uri.parse(ApiEndpoints.pendingBookings),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> bookingsJson = jsonResponse['data'] ?? [];

        return bookingsJson.map((json) => BookingModel.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load pending bookings: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching pending bookings: $e');
    }
  }

  /// Get booking history (paid bookings)
  Future<List<BookingModel>> getBookingHistory() async {
    try {
      final Box profileBox = HiveService().profileBox;
      final String? token = profileBox.get('authToken');

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await client.get(
        Uri.parse(ApiEndpoints.bookingHistory),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> bookingsJson = jsonResponse['data'] ?? [];

        return bookingsJson.map((json) => BookingModel.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load booking history: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching booking history: $e');
    }
  }

  /// Get single booking by ID
  Future<BookingModel> getBookingById(String id) async {
    try {
      final Box profileBox = HiveService().profileBox;
      final String? token = profileBox.get('authToken');

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await client.get(
        Uri.parse(ApiEndpoints.bookingById(id)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final Map<String, dynamic> bookingJson =
            jsonResponse['data'] ?? jsonResponse['booking'];

        return BookingModel.fromJson(bookingJson);
      } else {
        throw Exception('Failed to load booking: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching booking: $e');
    }
  }

  /// Create new booking (same API as web)
  Future<BookingModel> createBooking({
    required String serviceId,
    required String bikeModel,
    required DateTime date,
    String notes = '',
    bool requestedPickupDropoff = false,
    String pickupAddress = '',
    String dropoffAddress = '',
    Map<String, double>? pickupCoordinates,
    Map<String, double>? dropoffCoordinates,
  }) async {
    try {
      final Box profileBox = HiveService().profileBox;
      final String? token = profileBox.get('authToken');

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final body = <String, dynamic>{
        'serviceId': serviceId,
        'bikeModel': bikeModel,
        'date': date.toIso8601String(),
        'notes': notes,
        'requestedPickupDropoff': requestedPickupDropoff,
        'pickupAddress': pickupAddress,
        'dropoffAddress': dropoffAddress,
      };
      if (requestedPickupDropoff) {
        if (pickupCoordinates != null) {
          body['pickupCoordinates'] = pickupCoordinates;
        }
        if (dropoffCoordinates != null) {
          body['dropoffCoordinates'] = dropoffCoordinates;
        }
      }

      final response = await client.post(
        Uri.parse(ApiEndpoints.bookings),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final Map<String, dynamic> bookingJson = jsonResponse['data'];

        return BookingModel.fromJson(bookingJson);
      } else {
        throw Exception('Failed to create booking: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating booking: $e');
    }
  }
}
