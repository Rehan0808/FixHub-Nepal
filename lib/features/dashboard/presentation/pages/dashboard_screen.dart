import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/services/hive_services.dart';
import '../../../../theme/theme_data.dart';
import '../../../bookings/data/datasources/bookings_remote_datasource.dart';
import '../../../bookings/data/models/booking_model.dart';
import 'package:intl/intl.dart';
import '../../../chat/presentation/pages/chat_screen.dart';
import '../../../chat/presentation/pages/admin_chat_screen.dart';
import '../../../notifications/services/notification_service.dart';
import '../../../notifications/presentation/pages/notification_screen.dart';
import '../../../support/presentation/widgets/report_problem_dialog.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final BookingsRemoteDataSource _bookingsDataSource =
      BookingsRemoteDataSource();

  List<BookingModel> _allBookings = [];
  bool _isLoading = true;
  String? _errorMessage;

  String _userName = 'User';
  int _loyaltyPoints = 0;

  int get _upcomingCount => _allBookings
      .where(
        (b) =>
            (b.status == 'Pending' || b.status == 'In Progress') &&
            b.date.isAfter(DateTime.now()),
      )
      .length;

  int get _completedCount =>
      _allBookings.where((b) => b.status == 'Completed').length;

  int get _totalBookings => _allBookings.length;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchBookings();
    // Start notification polling now that user is logged in
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationService>().init();
    });
  }

  Future<void> _loadUserData() async {
    try {
      final Box profileBox = HiveService().profileBox;
      final String? token = profileBox.get('authToken');

      // Fetch fresh user profile from backend
      if (token != null) {
        try {
          final response = await http.get(
            Uri.parse(ApiEndpoints.userProfile),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          );

          if (response.statusCode == 200) {
            final jsonResponse = json.decode(response.body);
            final userData = jsonResponse['data'];

            setState(() {
              _userName = userData['fullName'] ?? 'User';
              _loyaltyPoints = userData['loyaltyPoints'] ?? 0;
            });

            // Save to Hive for offline access
            await profileBox.put('userName', _userName);
            await profileBox.put('loyaltyPoints', _loyaltyPoints);
            return;
          }
        } catch (e) {
          print('Error fetching profile: $e');
        }
      }

      // Fallback to cached data
      setState(() {
        _userName = profileBox.get('userName', defaultValue: 'User');
        _loyaltyPoints = profileBox.get('loyaltyPoints', defaultValue: 0);
      });
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _fetchBookings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final bookings = await _bookingsDataSource.getUserBookings(limit: 50);
      setState(() {
        _allBookings = bookings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _fetchBookings,
        color: AppTheme.primary,
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 120,
              pinned: true,
              backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
              elevation: 0,
              actions: [
                // 🔔 Notification bell with unread badge
                Consumer<NotificationService>(
                  builder: (_, notifSvc, __) {
                    final count = notifSvc.unreadCount;
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        IconButton(
                          icon: Icon(Icons.notifications_outlined,
                              color: Theme.of(context).colorScheme.onPrimary),
                          tooltip: 'Notifications',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const NotificationScreen(),
                              ),
                            );
                          },
                        ),
                        if (count > 0)
                          Positioned(
                            right: 6,
                            top: 6,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                  minWidth: 16, minHeight: 16),
                              child: Text(
                                count > 9 ? '9+' : '$count',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.support_agent_rounded,
                      color: Theme.of(context).colorScheme.onPrimary),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminChatScreen(),
                      ),
                    );
                  },
                  tooltip: 'Chat with Admin',
                ),
                IconButton(
                  icon: Icon(Icons.chat_bubble_outline,
                      color: Theme.of(context).colorScheme.onPrimary),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChatScreen(),
                      ),
                    );
                  },
                  tooltip: 'AI Chatbot',
                ),
                const SizedBox(width: 8),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primaryContainer
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Flexible(
                            child: Text(
                              'Welcome, $_userName',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Your vehicle\'s health at a glance.',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimary
                                  .withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Header
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.grid_view_rounded,
                                  size: 14,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'OVERVIEW',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(context).colorScheme.primary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Stats Grid
                    if (_isLoading)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      )
                    else if (_errorMessage != null)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 60,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Failed to load dashboard',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _errorMessage!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _fetchBookings,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                ),
                                child: Text(
                                  'Retry',
                                  style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  'UPCOMING',
                                  _upcomingCount.toString(),
                                  Icons.calendar_today_rounded,
                                  Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  'COMPLETED',
                                  _completedCount.toString(),
                                  Icons.check_circle_outline,
                                  AppTheme.success,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  'TOTAL BOOKINGS',
                                  _totalBookings.toString(),
                                  Icons.receipt_long,
                                  AppTheme.accent,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  'LOYALTY POINTS',
                                  _loyaltyPoints.toString(),
                                  Icons.star_border,
                                  Colors.purple,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // Recent Activity Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Recent Activity',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: Theme.of(context).colorScheme.onSurface,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  // Navigate to full booking history
                                },
                                child: Row(
                                  children: [
                                    Text(
                                      'View history',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_forward,
                                      size: 16,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Recent Bookings
                          if (_allBookings.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(40.0),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.inbox_outlined,
                                      size: 60,
                                      color: AppTheme.textLight.withOpacity(
                                        0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No bookings yet',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textGray,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Book a service to get started',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppTheme.textLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            ...(_allBookings.take(5).map((booking) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildBookingCard(booking),
                              );
                            }).toList()),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Theme.of(context).colorScheme.onSurface,
              letterSpacing: -1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(BookingModel booking) {
    Color statusColor;
    Color statusBgColor;

    switch (booking.status) {
      case 'In Progress':
        statusColor = AppTheme.accent;
        statusBgColor = AppTheme.accent.withOpacity(0.1);
        break;
      case 'Completed':
        statusColor = AppTheme.success;
        statusBgColor = AppTheme.success.withOpacity(0.1);
        break;
      case 'Cancelled':
        statusColor = Colors.red;
        statusBgColor = Colors.red.withOpacity(0.1);
        break;
      default:
        statusColor = Colors.blue;
        statusBgColor = Colors.blue.withOpacity(0.1);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.directions_car,
              color: AppTheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.bikeModel,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  booking.serviceType,
                  style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        DateFormat(
                          'MMM dd, yyyy \'at\' HH:mm',
                        ).format(booking.date),
                        style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              booking.status,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
