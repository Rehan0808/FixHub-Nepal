// class ApiEndpoints {
//   static const String baseUrl = 'http://192.168.1.75:5000/api';
//   //  static const String baseUrl = 'http://localhost:5000/api';

//   static const String login = '$baseUrl/auth/login';
//   static const String signup = '$baseUrl/auth/register';
//   static const String uploadProfileImage = '$baseUrl/profile/upload';
// }

import 'package:flutter/foundation.dart';

class ApiEndpoints {
  // 🔹 Physical device: use your PC's current IP. Change if IP changes.
  static const String baseUrl = 'http://192.168.1.82:5050/api';

  // Web uses localhost, device uses baseUrl (IP)
  static String get resolvedBaseUrl =>
      kIsWeb ? 'http://localhost:5050/api' : baseUrl;

  /// Base URL for static uploads (images). Backend serves at /uploads.
  static String get uploadsBaseUrl {
    final b = resolvedBaseUrl;
    return b.endsWith('/api') ? b.substring(0, b.length - 4) : b;
  }

  /// Build full URL for a service image path from backend (e.g. "uploads/xyz.jpg").
  /// Handles Windows backslashes and paths that omit "uploads/".
  static String serviceImageUrl(String imagePath) {
    if (imagePath.isEmpty) return '';
    if (imagePath.startsWith('http')) return imagePath;
    // Normalize: Windows may store "uploads\image-xxx.jpg"
    String path = imagePath.replaceAll(r'\', '/').trim();
    if (!path.startsWith('/') && !path.startsWith('uploads')) {
      path = 'uploads/$path';
    }
    if (!path.startsWith('/')) path = '/$path';
    return '$uploadsBaseUrl$path';
  }

  static String get login => '$resolvedBaseUrl/auth/login';
  static String get signup => '$resolvedBaseUrl/auth/register';
  static String get uploadProfileImage => '$resolvedBaseUrl/profile/upload';
  static String get forgotPassword => '$resolvedBaseUrl/auth/forgot-password';
  static String get changePassword => '$resolvedBaseUrl/auth/change-password';
  static String get forgotPasswordOtp => '$resolvedBaseUrl/auth/forgot-password-otp';
  static String get resetPasswordOtp => '$resolvedBaseUrl/auth/reset-password-otp';

  // Services
  static String get services => '$resolvedBaseUrl/user/services';
  static String serviceById(String id) => '$resolvedBaseUrl/user/services/$id';

  // Bookings
  static String get bookings => '$resolvedBaseUrl/user/bookings';
  static String get pendingBookings => '$resolvedBaseUrl/user/bookings/pending';
  static String get bookingHistory => '$resolvedBaseUrl/user/bookings/history';
  static String bookingById(String id) => '$resolvedBaseUrl/user/bookings/$id';

  // Payments
  static String get initiateEsewa => '$resolvedBaseUrl/payment/esewa/initiate';
  static String get verifyEsewa => '$resolvedBaseUrl/payment/esewa/verify';

  // User Profile
  static String get userProfile => '$resolvedBaseUrl/user/profile';
  /// POST profile picture only (mobile uses this; web uses PUT /user/profile).
  static String get userProfilePictureUpload => '$resolvedBaseUrl/user/profile/picture';

  // Chat endpoints
  static String get chatMessages => '$resolvedBaseUrl/messages';
  static String get sendMessage => '$resolvedBaseUrl/messages';

  // Notification endpoints
  static String get notifications => '$resolvedBaseUrl/notifications';
  static String notificationMarkRead(String id) => '$resolvedBaseUrl/notifications/$id/read';
  static String get notificationsMarkAllRead => '$resolvedBaseUrl/notifications/read-all';
}
