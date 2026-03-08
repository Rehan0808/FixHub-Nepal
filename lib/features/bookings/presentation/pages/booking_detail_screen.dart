import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:intl/intl.dart';
import '../../../../theme/theme_data.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../bookings/data/models/booking_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/services/hive_services.dart';
import 'esewa_payment_webview_screen.dart';

class BookingDetailScreen extends StatefulWidget {
  final BookingModel booking;

  const BookingDetailScreen({super.key, required this.booking});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  bool _isLoadingPayment = false;
  late bool _isPaid;
  late String _paymentStatus;
  late String _paymentMethod;

  @override
  void initState() {
    super.initState();
    _isPaid = widget.booking.isPaid;
    _paymentStatus = widget.booking.paymentStatus;
    _paymentMethod = widget.booking.paymentMethod;
  }

  Color get _statusColor {
    switch (widget.booking.status) {
      case 'In Progress': return AppTheme.accent;
      case 'Completed': return AppTheme.success;
      case 'Cancelled': return Colors.red;
      default: return Colors.blue;
    }
  }

  IconData get _statusIcon {
    switch (widget.booking.status) {
      case 'In Progress': return Icons.build_rounded;
      case 'Completed': return Icons.check_circle_rounded;
      case 'Cancelled': return Icons.cancel_rounded;
      default: return Icons.hourglass_top_rounded;
    }
  }

  Future<void> _initiatePayment() async {
    // Check if fingerprint is enabled for payments
    final profileBox = HiveService().profileBox;
    final bool isFingerprintEnabled = profileBox.get('isFingerprintEnabled') ?? false;

    if (isFingerprintEnabled) {
      final LocalAuthentication auth = LocalAuthentication();
      try {
        final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
        final bool canAuthenticate =
            canAuthenticateWithBiometrics || await auth.isDeviceSupported();

        if (canAuthenticate) {
          final bool authenticated = await auth.authenticate(
            localizedReason: 'Please scan your fingerprint to authorize payment',
            options: const AuthenticationOptions(
              stickyAuth: true,
              biometricOnly: true,
            ),
          );

          if (!authenticated) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Authentication failed. Payment cancelled.')),
              );
            }
            return;
          }
        }
      } catch (e) {
        debugPrint("AUTH_ERROR: $e");
        // Fallback or handle error if needed
      }
    }

    setState(() => _isLoadingPayment = true);
    try {
      final token = profileBox.get('authToken');
      
      final response = await http.post(
        Uri.parse(ApiEndpoints.initiateEsewa),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'bookingId': widget.booking.id}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (kIsWeb) {
          // Construct an HTML form that auto-submits to eSewa
          final htmlContent = '''
            <!DOCTYPE html>
            <html>
            <body onload="document.forms[0].submit()">
              <form action="\${data['ESEWA_URL']}" method="POST">
                <input type="hidden" id="amount" name="amount" value="\${data['amount']}" required>
                <input type="hidden" id="tax_amount" name="tax_amount" value="\${data['tax_amount']}" required>
                <input type="hidden" id="total_amount" name="total_amount" value="\${data['total_amount']}" required>
                <input type="hidden" id="transaction_uuid" name="transaction_uuid" value="\${data['transaction_uuid']}" required>
                <input type="hidden" id="product_code" name="product_code" value="\${data['product_code']}" required>
                <input type="hidden" id="product_service_charge" name="product_service_charge" value="\${data['product_service_charge']}" required>
                <input type="hidden" id="product_delivery_charge" name="product_delivery_charge" value="\${data['product_delivery_charge']}" required>
                <input type="hidden" id="success_url" name="success_url" value="\${data['success_url']}" required>
                <input type="hidden" id="failure_url" name="failure_url" value="\${data['failure_url']}" required>
                <input type="hidden" id="signed_field_names" name="signed_field_names" value="\${data['signed_field_names']}" required>
                <input type="hidden" id="signature" name="signature" value="\${data['signature']}" required>
              </form>
              <div style="display:flex; justify-content:center; align-items:center; height:100vh; font-family:sans-serif;">
                <h2>Redirecting to eSewa...</h2>
              </div>
            </body>
            </html>
          ''';

          // Convert HTML to a data URI to launch in browser
          final dataUri = Uri.dataFromString(
            htmlContent,
            mimeType: 'text/html',
            encoding: Encoding.getByName('utf-8'),
          );

          if (await canLaunchUrl(dataUri)) {
            await launchUrl(dataUri, mode: LaunchMode.externalApplication);
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Could not open payment portal on Web')),
              );
            }
          }
        } else {
          // On mobile, use our in-app webview
          if (mounted) {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EsewaPaymentWebViewScreen(paymentData: data),
              ),
            );

            if (result != null && result is Map) {
              if (result['status'] == 'success') {
                if (mounted) {
                  setState(() {
                    _isPaid = true;
                    _paymentStatus = 'Paid';
                    _paymentMethod = 'eSewa';
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Payment Successful!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Payment Cancelled or Failed')),
                  );
                }
              }
            }
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to initiate payment: \${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initiating payment: \$e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingPayment = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
    final dateStr = DateFormat('EEEE, MMMM dd, yyyy').format(booking.date);
    final timeStr = DateFormat('hh:mm a').format(booking.date);
    final bookedOn = DateFormat('MMM dd, yyyy').format(booking.createdAt);
    final hasImage = booking.serviceImage.isNotEmpty;
    final imageUrl = hasImage ? ApiEndpoints.serviceImageUrl(booking.serviceImage) : '';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // ── Hero Image AppBar ──────────────────────────────────────────
          SliverAppBar(
            expandedHeight: hasImage ? 280 : 160,
            pinned: true,
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            foregroundColor: Theme.of(context).appBarTheme.titleTextStyle?.color ?? Theme.of(context).colorScheme.onSurface,
            flexibleSpace: FlexibleSpaceBar(
              background: hasImage
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _gradientBg(),
                        ),
                        // dark overlay so text stays readable
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.2),
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                        // Service name at bottom of image
                        Positioned(
                          left: 20,
                          right: 20,
                          bottom: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking.serviceType,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              _StatusChip(
                                label: booking.status,
                                color: _statusColor,
                                icon: _statusIcon,
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        _gradientBg(),
                        Positioned(
                          left: 20,
                          right: 20,
                          bottom: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking.serviceType,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 6),
                              _StatusChip(
                                label: booking.status,
                                color: _statusColor,
                                icon: _statusIcon,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          // ── Content ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Booking ID
                  _SectionCard(
                    children: [
                      _TileRow(
                        icon: Icons.tag_rounded,
                        label: 'Booking ID',
                        value: '#${booking.id}',
                        valueStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textGray,
                          fontFamily: 'monospace',
                        ),
                      ),
                      _TileRow(
                        icon: Icons.event_note_rounded,
                        label: 'Booked on',
                        value: bookedOn,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Schedule
                  _SectionHeader(title: 'Schedule'),
                  const SizedBox(height: 10),
                  _SectionCard(
                    children: [
                      _TileRow(icon: Icons.calendar_today_rounded, label: 'Date', value: dateStr),
                      _TileRow(icon: Icons.access_time_rounded, label: 'Time', value: timeStr),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Vehicle
                  _SectionHeader(title: 'Vehicle'),
                  const SizedBox(height: 10),
                  _SectionCard(
                    children: [
                      _TileRow(icon: Icons.two_wheeler_rounded, label: 'Model', value: booking.bikeModel),
                    ],
                  ),

                  // Pickup / Dropoff
                  if (booking.requestedPickupDropoff) ...[
                    const SizedBox(height: 16),
                    _SectionHeader(title: 'Pickup & Dropoff'),
                    const SizedBox(height: 10),
                    _SectionCard(
                      children: [
                        if (booking.pickupAddress.isNotEmpty)
                          _TileRow(icon: Icons.location_on_rounded, label: 'Pickup', value: booking.pickupAddress, multiLine: true),
                        if (booking.dropoffAddress.isNotEmpty)
                          _TileRow(icon: Icons.flag_rounded, label: 'Dropoff', value: booking.dropoffAddress, multiLine: true),
                        if (booking.pickupDropoffDistance > 0)
                          _TileRow(icon: Icons.route_rounded, label: 'Distance', value: '${booking.pickupDropoffDistance.toStringAsFixed(1)} km'),
                      ],
                    ),
                  ],

                  if (booking.notes.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _SectionHeader(title: 'Notes'),
                    const SizedBox(height: 10),
                    _SectionCard(
                      children: [
                        _TileRow(icon: Icons.notes_rounded, label: 'Your note', value: booking.notes, multiLine: true),
                      ],
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Payment
                  _SectionHeader(title: 'Payment'),
                  const SizedBox(height: 10),
                  _SectionCard(
                    children: [
                      _TileRow(icon: Icons.payments_outlined, label: 'Method', value: _paymentMethod),
                      _TileRow(
                        icon: Icons.receipt_long_rounded,
                        label: 'Payment Status',
                        value: _paymentStatus,
                        valueColor: _isPaid ? AppTheme.success : null,
                      ),
                      if (booking.discountApplied) ...[
                        _TileRow(icon: Icons.price_check_rounded, label: 'Base Cost', value: 'Rs. ${booking.totalCost.toInt()}'),
                        _TileRow(icon: Icons.discount_rounded, label: 'Discount', value: '- Rs. ${booking.discountAmount.toInt()}', valueColor: AppTheme.success),
                      ],
                      if (booking.pickupDropoffCost > 0)
                        _TileRow(icon: Icons.local_shipping_outlined, label: 'Pickup/Drop Cost', value: '+ Rs. ${booking.pickupDropoffCost.toInt()}'),
                    ],
                  ),

                  // Total amount highlighted
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Amount',
                            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                        Text('Rs. ${booking.finalAmount.toInt()}',
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),

                  if (booking.pointsAwarded > 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.purple.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.purple, size: 20),
                          const SizedBox(width: 10),
                          Text('You earned ${booking.pointsAwarded} loyalty points from this booking',
                              style: const TextStyle(fontSize: 13, color: Colors.purple, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Pay Now Button if not paid and not cancelled
                  if (_isPaid) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.success.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.check_circle_rounded, color: Colors.green, size: 22),
                          SizedBox(width: 8),
                          Text(
                            'Paid',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ] else if (booking.status != 'Cancelled') ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoadingPayment ? null : _initiatePayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoadingPayment
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.network(
                                    'https://esewa.com.np/common/images/esewa-logo.png',
                                    height: 20,
                                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.payment),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Pay with eSewa',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _gradientBg() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.dark, AppTheme.darkLight],
        ),
      ),
      child: Center(
        child: Icon(Icons.build_circle_outlined, size: 80, color: Colors.white.withOpacity(0.15)),
      ),
    );
  }
}

// ── Helper widgets ─────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) => Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          letterSpacing: 0.5,
        ),
      );
}

class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    // Filter out widgets that might be empty (if conditions produce nothing)
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _TileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool multiLine;
  final Color? valueColor;
  final TextStyle? valueStyle;

  const _TileRow({
    required this.icon,
    required this.label,
    required this.value,
    this.multiLine = false,
    this.valueColor,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: multiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: AppTheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: valueStyle ??
                      TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: valueColor ?? Theme.of(context).colorScheme.onSurface,
                        height: 1.4,
                      ),
                  maxLines: multiLine ? 5 : 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _StatusChip({required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
