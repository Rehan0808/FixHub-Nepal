import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../../../../theme/theme_data.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../services/data/datasources/services_remote_datasource.dart';
import '../../../services/data/models/service_model.dart';
import '../../../bookings/data/datasources/bookings_remote_datasource.dart';
import '../../../../core/widget/location_picker_screen.dart';
import 'package:latlong2/latlong.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final ServicesRemoteDataSource _servicesDataSource =
      ServicesRemoteDataSource();
  List<ServiceModel> _allServices = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final services = await _servicesDataSource.getServices();
      setState(() {
        _allServices = services;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  List<ServiceModel> get _filteredServices {
    if (_searchQuery.isEmpty) return _allServices;
    return _allServices.where((service) {
      final name = service.name.toLowerCase();
      final description = service.description.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || description.contains(query);
    }).toList();
  }

  IconData _getServiceIcon(String serviceName) {
    final name = serviceName.toLowerCase();
    if (name.contains('engine') || name.contains('overhaul')) {
      return Icons.settings_outlined;
    } else if (name.contains('clean')) {
      return Icons.cleaning_services_outlined;
    } else if (name.contains('oil')) {
      return Icons.oil_barrel_outlined;
    } else if (name.contains('brake')) {
      return Icons.disc_full_outlined;
    } else if (name.contains('tire') || name.contains('wheel')) {
      return Icons.tire_repair;
    } else if (name.contains('battery')) {
      return Icons.battery_charging_full;
    } else if (name.contains('ac') || name.contains('air')) {
      return Icons.ac_unit;
    } else {
      return Icons.build_circle_outlined;
    }
  }

  Color _getServiceColor(int index) {
    final colors = [
      AppTheme.primary,
      AppTheme.accent,
      AppTheme.success,
      Colors.orange,
      Colors.blue,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
    ];
    return colors[index % colors.length];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _fetchServices,
        color: AppTheme.primary,
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).appBarTheme.backgroundColor,
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
                              'Our Services',
                              style: TextStyle(
                                color: Theme.of(context).appBarTheme.titleTextStyle?.color ?? Theme.of(context).colorScheme.onSurface,
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Professional vehicle care',
                            style: TextStyle(
                              color: (Theme.of(context).appBarTheme.titleTextStyle?.color ?? Theme.of(context).colorScheme.onSurface).withOpacity(0.7),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  style: const TextStyle(fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'Search services...',
                    hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Theme.of(context).colorScheme.onSurfaceVariant),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Theme.of(context).scaffoldBackgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Loading, Error, or Services Grid
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: AppTheme.primary),
                ),
              )
            else if (_errorMessage != null)
              SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 80,
                          color: AppTheme.primary,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Failed to load services',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textGray,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textLight,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _fetchServices,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Retry',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                sliver: _filteredServices.isEmpty
                    ? SliverToBoxAdapter(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 60),
                              Icon(
                                Icons.search_off,
                                size: 80,
                                color: AppTheme.textLight.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No services found',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textGray,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try a different search term',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 0.75,
                            ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final service = _filteredServices[index];
                          return _buildServiceCard(service, index);
                        }, childCount: _filteredServices.length),
                      ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(ServiceModel service, int index) {
    final color = _getServiceColor(index);
    final icon = _getServiceIcon(service.name);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServiceDetailsScreen(service: service),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
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
            // Image or Icon Container
            Expanded(
              flex: 4,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: service.image.isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        child: Image.network(
                          ApiEndpoints.serviceImageUrl(service.image),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(icon, size: 48, color: color);
                          },
                        ),
                      )
                    : Icon(icon, size: 48, color: color),
              ),
            ),

            // Content
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rating Badge
                    if (service.rating > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              size: 12,
                          color: AppTheme.accent,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              service.rating.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 8), // Adjusted spacing

                    // Service Name
                    Text(
                      service.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Duration
                    if (service.duration != null && service.duration!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 12, color: AppTheme.textLight),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '${service.duration!} hrs',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textGray,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 8),

                    // Price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            'Rs. ${service.price.toInt()}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: AppTheme.textLight,
                        ),
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
}

// Service Details Screen
class ServiceDetailsScreen extends StatelessWidget {
  final ServiceModel service;

  const ServiceDetailsScreen({super.key, required this.service});

  IconData _getServiceIcon(String serviceName) {
    final name = serviceName.toLowerCase();
    if (name.contains('engine') || name.contains('overhaul')) {
      return Icons.settings_outlined;
    } else if (name.contains('clean')) {
      return Icons.cleaning_services_outlined;
    } else if (name.contains('oil')) {
      return Icons.oil_barrel_outlined;
    } else if (name.contains('brake')) {
      return Icons.disc_full_outlined;
    } else if (name.contains('tire') || name.contains('wheel')) {
      return Icons.tire_repair;
    } else if (name.contains('battery')) {
      return Icons.battery_charging_full;
    } else if (name.contains('ac') || name.contains('air')) {
      return Icons.ac_unit;
    } else {
      return Icons.build_circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final icon = _getServiceIcon(service.name);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Service Image/Icon
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              background: service.image.isNotEmpty
                  ? Image.network(
                      ApiEndpoints.serviceImageUrl(service.image),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          ),
                          child: Center(
                            child: Icon(icon, size: 100, color: Theme.of(context).colorScheme.primary),
                          ),
                        );
                      },
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      ),
                      child: Center(
                        child: Icon(icon, size: 100, color: Theme.of(context).colorScheme.primary),
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
                  // Rating Badge
                  if (service.rating > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            size: 16,
                            color: AppTheme.accent,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${service.rating.toStringAsFixed(1)} (${service.numReviews} reviews)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),

                  Text(
                    service.name,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Theme.of(context).colorScheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Info Cards
                  Row(
                    children: [
                      if (service.duration != null)
                        Expanded(
                          child: _buildInfoCard(
                            context,
                            icon: Icons.access_time_rounded,
                            label: 'Duration',
                            value: service.duration!,
                          ),
                        ),
                      if (service.duration != null) const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoCard(
                          context,
                          icon: Icons.payments_outlined,
                          label: 'Price',
                          value: 'Rs. ${service.price.toInt()}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Description
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    service.description,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppTheme.textGray,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Features
                  Text(
                    'What\'s Included',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem('Certified mechanics'),
                  _buildFeatureItem('Quality guaranteed'),
                  _buildFeatureItem('Warranty included'),
                  _buildFeatureItem('Free consultation'),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookingScreen(service: service),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'Book This Service',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppTheme.textGray),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.dark,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppTheme.success, size: 20),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(fontSize: 15, color: AppTheme.textGray),
          ),
        ],
      ),
    );
  }
}

// Booking Screen
class BookingScreen extends StatefulWidget {
  final ServiceModel service;

  const BookingScreen({super.key, required this.service});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _vehicleNameController = TextEditingController();
  final _vehicleNumberController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedTime;
  final _problemDescriptionController = TextEditingController();

  bool _requestPickup = false;
  final _pickupAddressController = TextEditingController();
  final _dropoffAddressController = TextEditingController();
  Map<String, double>? _pickupCoords;
  Map<String, double>? _dropoffCoords;
  String? _fetchingLocation; // 'pickup' | 'dropoff'
  bool _isSubmitting = false;

  final BookingsRemoteDataSource _bookingsDataSource = BookingsRemoteDataSource();

  final List<String> _timeSlots = [
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
    '05:00 PM',
  ];

  IconData _getServiceIcon(String serviceName) {
    final name = serviceName.toLowerCase();
    if (name.contains('engine') || name.contains('overhaul')) {
      return Icons.settings_outlined;
    } else if (name.contains('clean')) {
      return Icons.cleaning_services_outlined;
    } else if (name.contains('oil')) {
      return Icons.oil_barrel_outlined;
    } else if (name.contains('brake')) {
      return Icons.disc_full_outlined;
    } else if (name.contains('tire') || name.contains('wheel')) {
      return Icons.tire_repair;
    } else if (name.contains('battery')) {
      return Icons.battery_charging_full;
    } else if (name.contains('ac') || name.contains('air')) {
      return Icons.ac_unit;
    } else {
      return Icons.build_circle_outlined;
    }
  }

  @override
  void dispose() {
    _vehicleNameController.dispose();
    _vehicleNumberController.dispose();
    _problemDescriptionController.dispose();
    _pickupAddressController.dispose();
    _dropoffAddressController.dispose();
    super.dispose();
  }

  /// Fetch current location and reverse geocode to address (same as web - Nominatim).
  Future<void> _fetchUserLocation(String field) async {
    setState(() => _fetchingLocation = field);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permission is required to use this feature')),
            );
          }
          setState(() => _fetchingLocation = null);
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission was permanently denied. Enable it in device settings.')),
          );
        }
        setState(() => _fetchingLocation = null);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final lat = position.latitude;
      final lng = position.longitude;

      if (!mounted) return;
      
      // Use the new Map Picker screen
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LocationPickerScreen(
            title: field == 'pickup' ? 'Select Pickup Location' : 'Select Dropoff Location',
            initialPosition: LatLng(lat, lng),
          ),
        ),
      );

      if (result != null && result is Map<String, dynamic>) {
        setState(() {
          _fetchingLocation = null;
          if (field == 'pickup') {
            _pickupAddressController.text = result['address'];
            _pickupCoords = {'lat': result['lat'], 'lng': result['lng']};
          } else {
            _dropoffAddressController.text = result['address'];
            _dropoffCoords = {'lat': result['lat'], 'lng': result['lng']};
          }
        });
      } else {
        setState(() => _fetchingLocation = null);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _fetchingLocation = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not get location: $e')),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _confirmBooking() async {
    final vehicleName = _vehicleNameController.text.trim();
    final vehicleNumber = _vehicleNumberController.text.trim();
    if (vehicleName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter Vehicle Name')),
      );
      return;
    }
    if (vehicleNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter Vehicle Number')),
      );
      return;
    }
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date')),
      );
      return;
    }
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time slot')),
      );
      return;
    }
    if (_requestPickup) {
      if (_pickupAddressController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter or fetch pickup address')),
        );
        return;
      }
      if (_dropoffAddressController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter or fetch dropoff address')),
        );
        return;
      }
    }

    setState(() => _isSubmitting = true);
    try {
      final timeOfDay = _parseTime(_selectedTime!);
      final dateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        timeOfDay.hour,
        timeOfDay.minute,
      );
      final bikeModel = '$vehicleName ($vehicleNumber)';
      await _bookingsDataSource.createBooking(
        serviceId: widget.service.id,
        bikeModel: bikeModel,
        date: dateTime,
        notes: _problemDescriptionController.text.trim(),
        requestedPickupDropoff: _requestPickup,
        pickupAddress: _requestPickup ? _pickupAddressController.text.trim() : '',
        dropoffAddress: _requestPickup ? _dropoffAddressController.text.trim() : '',
        pickupCoordinates: _requestPickup ? _pickupCoords : null,
        dropoffCoordinates: _requestPickup ? _dropoffCoords : null,
      );
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          title: const Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: AppTheme.success, size: 28),
              SizedBox(width: 12),
              Flexible(
                child: Text(
                  'Booking Confirmed!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          content: Text(
            'Your booking for ${widget.service.name} has been confirmed.',
            style: const TextStyle(fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  TimeOfDay _parseTime(String timeStr) {
    final parts = timeStr.replaceAll(RegExp(r'\s*(AM|PM)\s*'), ' ').split(RegExp(r'[\s:]'));
    int h = int.tryParse(parts[0]) ?? 0;
    int m = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
    if (timeStr.toUpperCase().contains('PM') && h < 12) h += 12;
    if (timeStr.toUpperCase().contains('AM') && h == 12) h = 0;
    return TimeOfDay(hour: h, minute: m);
  }

  @override
  Widget build(BuildContext context) {
    final icon = _getServiceIcon(widget.service.name);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Service'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        foregroundColor: Theme.of(context).appBarTheme.titleTextStyle?.color ?? Theme.of(context).colorScheme.onSurface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Summary
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: AppTheme.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.service.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.dark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rs. ${widget.service.price.toInt()}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Vehicle Name * (same as web)
            const Text(
              'Vehicle Name *',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.dark,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _vehicleNameController,
              decoration: InputDecoration(
                hintText: 'e.g. Yamaha FZ 250',
                prefixIcon: const Icon(Icons.directions_car_outlined, color: AppTheme.textLight, size: 20),
                filled: true,
                fillColor: AppTheme.backgroundLight,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.grayBorder)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.primary, width: 2)),
              ),
            ),
            const SizedBox(height: 20),

            // Vehicle Number * (same as web)
            const Text(
              'Vehicle Number *',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.dark,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _vehicleNumberController,
              decoration: InputDecoration(
                hintText: 'e.g. BA 2 PA 5555',
                prefixIcon: const Icon(Icons.tag, color: AppTheme.textLight, size: 20),
                filled: true,
                fillColor: AppTheme.backgroundLight,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.grayBorder)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.primary, width: 2)),
              ),
            ),
            const SizedBox(height: 20),

            // Appointment Date * & Appointment Time *
            const Text(
              'Appointment Date *',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.dark,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selectDate,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.grayBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: AppTheme.primary),
                    const SizedBox(width: 16),
                    Text(
                      _selectedDate == null
                          ? 'Choose a date'
                          : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                      style: TextStyle(
                        fontSize: 15,
                        color: _selectedDate == null
                            ? AppTheme.textLight
                            : AppTheme.dark,
                        fontWeight: _selectedDate == null
                            ? FontWeight.normal
                            : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Appointment Time *',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.dark,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _timeSlots.map((time) {
                final isSelected = _selectedTime == time;
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedTime = time;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primary
                          : AppTheme.backgroundLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primary
                            : AppTheme.grayBorder,
                      ),
                    ),
                    child: Text(
                      time,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? AppTheme.white : AppTheme.dark,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Problem Description (Optional) - same as web
            Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: AppTheme.textGray),
                const SizedBox(width: 6),
                const Text(
                  'Problem Description ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.dark,
                  ),
                ),
                Text(
                  '(Optional)',
                  style: TextStyle(fontSize: 12, color: AppTheme.textGray),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _problemDescriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Briefly describe the issue with your vehicle...',
                filled: true,
                fillColor: Theme.of(context).scaffoldBackgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Pick-up & Drop-off Service (same as web)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.backgroundLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.grayBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _requestPickup,
                        onChanged: (v) => setState(() => _requestPickup = v ?? false),
                        activeColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Pick-up & Drop-off Service',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.dark,
                              ),
                            ),
                            Text(
                              'Request Pick-up and Drop-off (+Rs. 200 flat)',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textGray,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (_requestPickup) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Pickup Address *',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.dark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _pickupAddressController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Enter pickup address',
                        prefixIcon: const Icon(Icons.location_on_outlined, color: AppTheme.textLight, size: 20),
                        suffixIcon: IconButton(
                          onPressed: _fetchingLocation != null
                              ? null
                              : () => _fetchUserLocation('pickup'),
                          icon: _fetchingLocation == 'pickup'
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
                                )
                              : const Icon(Icons.my_location, color: AppTheme.primary, size: 22),
                          tooltip: 'Use current location',
                        ),
                        filled: true,
                        fillColor: AppTheme.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.grayBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Dropoff Address *',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.dark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _dropoffAddressController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Enter dropoff address',
                        prefixIcon: const Icon(Icons.location_on_outlined, color: AppTheme.textLight, size: 20),
                        suffixIcon: IconButton(
                          onPressed: _fetchingLocation != null
                              ? null
                              : () => _fetchUserLocation('dropoff'),
                          icon: _fetchingLocation == 'dropoff'
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
                                )
                              : const Icon(Icons.my_location, color: AppTheme.primary, size: 22),
                          tooltip: 'Use current location',
                        ),
                        filled: true,
                        fillColor: AppTheme.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.grayBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You can tap the location icon to use your current address, or type manually.',
                      style: TextStyle(fontSize: 12, color: AppTheme.textGray),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Service Price', style: TextStyle(fontSize: 14, color: AppTheme.dark)),
                              Text('Rs. ${widget.service.price.toInt()}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Pick-up & Drop-off', style: TextStyle(fontSize: 14, color: AppTheme.dark)),
                              const Text('+ Rs. 200', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total Amount', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.dark)),
                              Text('Rs. ${widget.service.price.toInt() + 200}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Cancel & Confirm Booking (same as web)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppTheme.dark),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _confirmBooking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isSubmitting
                        ? CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.onPrimary)
                        : Text(
                            'Confirm Booking',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
