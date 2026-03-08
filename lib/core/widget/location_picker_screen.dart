import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../../theme/theme_data.dart';

class LocationPickerScreen extends StatefulWidget {
  final String title;
  final LatLng? initialPosition;
  final String? initialAddress;

  const LocationPickerScreen({
    super.key,
    required this.title,
    this.initialPosition,
    this.initialAddress,
  });

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late MapController _mapController;
  LatLng _markerPosition = const LatLng(27.7172, 85.324); // Default: Kathmandu
  String _currentAddress = '';
  List<dynamic> _suggestions = [];
  bool _isSearching = false;
  bool _isReverseGeocoding = false;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    if (widget.initialPosition != null) {
      _markerPosition = widget.initialPosition!;
    }
    if (widget.initialAddress != null) {
      _currentAddress = widget.initialAddress!;
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }

    setState(() => _isSearching = true);
    try {
      final encodedQuery = Uri.encodeComponent(query);
      final response = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/search?format=json&q=$encodedQuery&limit=5&countrycodes=np',
        ),
        headers: {'User-Agent': 'FixHubNepal/1.0'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _suggestions = jsonDecode(response.body);
        });
      }
    } catch (e) {
      debugPrint('Search error: $e');
    } finally {
      setState(() => _isSearching = false);
    }
  }

  Future<void> _reverseGeocode(LatLng position) async {
    setState(() => _isReverseGeocoding = true);
    try {
      final response = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${position.latitude}&lon=${position.longitude}',
        ),
        headers: {'User-Agent': 'FixHubNepal/1.0'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _currentAddress = data['display_name'] ?? '';
        });
      }
    } catch (e) {
      debugPrint('Reverse geocode error: $e');
    } finally {
      setState(() => _isReverseGeocoding = false);
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchLocation(query);
    });
  }

  void _handleSuggestionClick(Map<String, dynamic> suggestion) {
    final lat = double.parse(suggestion['lat']);
    final lon = double.parse(suggestion['lon']);
    final position = LatLng(lat, lon);

    setState(() {
      _markerPosition = position;
      _currentAddress = suggestion['display_name'];
      _suggestions = [];
      _searchController.clear();
    });

    _mapController.move(position, 15);
  }

  void _confirmSelection() {
    Navigator.pop(context, {
      'address': _currentAddress,
      'lat': _markerPosition.latitude,
      'lng': _markerPosition.longitude,
    });
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled.')),
        );
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')),
          );
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permissions are permanently denied, we cannot request permissions.'),
          ),
        );
      }
      return;
    }

    try {
      final Position position = await Geolocator.getCurrentPosition();
      final latLng = LatLng(position.latitude, position.longitude);

      setState(() {
        _markerPosition = latLng;
      });

      _mapController.move(latLng, 15);
      _reverseGeocode(latLng);
    } catch (e) {
      debugPrint('Location fetching error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // The Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _markerPosition,
              initialZoom: 15.0,
              onTap: (tapPosition, point) {
                setState(() {
                  _markerPosition = point;
                });
                _reverseGeocode(point);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.fixhub.nepal',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _markerPosition,
                    width: 80,
                    height: 80,
                    child: const Icon(
                      Icons.location_on,
                      color: AppTheme.primary,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Search Bar & Suggestions
          PositionEnvironment(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          hintText: 'Search location...',
                          prefixIcon: const Icon(Icons.search, color: AppTheme.primary),
                          suffixIcon: _isSearching
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : null,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                    if (_suggestions.isNotEmpty)
                      Card(
                        margin: const EdgeInsets.only(top: 4),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: _suggestions.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final suggestion = _suggestions[index];
                            return ListTile(
                              leading: const Icon(Icons.map_outlined),
                              title: Text(
                                suggestion['display_name'],
                                style: const TextStyle(fontSize: 14),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () => _handleSuggestionClick(suggestion),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Info Card
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Floating Action Button for Current Location
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: FloatingActionButton(
                    heroTag: 'location_fab',
                    onPressed: _getCurrentLocation,
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.my_location, color: AppTheme.primary),
                  ),
                ),
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.pin_drop, color: AppTheme.primary, size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _isReverseGeocoding
                                  ? const LinearProgressIndicator()
                                  : Text(
                                      _currentAddress.isEmpty
                                          ? 'Select a location on map'
                                          : _currentAddress,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _currentAddress.isEmpty ? null : _confirmSelection,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Confirm Location',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Wrapper for Positioned because of some lints/complexity
class PositionEnvironment extends StatelessWidget {
  final Widget child;
  const PositionEnvironment({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: child,
    );
  }
}
