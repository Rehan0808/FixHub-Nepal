import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/services/hive_services.dart';
import '../../../bookings/data/models/booking_model.dart';

class AdminBookingsDataSource {
  final HiveService _hiveService = HiveService();

  String? get _token => _hiveService.profileBox.get('authToken');

  Future<List<BookingModel>> getAllBookings({String? status}) async {
    try {
      String url = '${ApiEndpoints.resolvedBaseUrl}/admin/bookings';
      if (status != null && status != 'All') {
        url += '?status=$status';
      }

      print('Fetching admin bookings from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List<dynamic> bookingsJson = jsonResponse['data'] ?? [];
        
        return bookingsJson.map((json) => BookingModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load bookings: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching admin bookings: $e');
      throw Exception('Could not load bookings: $e');
    }
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      final url = '${ApiEndpoints.resolvedBaseUrl}/admin/bookings/$bookingId/status';

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode({'status': status}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update booking status');
      }
    } catch (e) {
      throw Exception('Could not update status: $e');
    }
  }
}
