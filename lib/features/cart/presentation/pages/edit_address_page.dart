import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import '../../../../core/services/map_location_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';

class EditAddressPage extends StatefulWidget {
  const EditAddressPage({super.key});

  @override
  State<EditAddressPage> createState() => _EditAddressPageState();
}

class _EditAddressPageState extends State<EditAddressPage> {
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _floorController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();

  // Sheet height tracking
  final DraggableScrollableController _sheetController = DraggableScrollableController();
  bool _isExpanded = false;

  // Google Map Controller & State
  GoogleMapController? _mapController;
  MapType _currentMapType = MapType.normal;

  // Selected Location (Default: SETEC Institute, Phnom Penh)
  double _currentLat = 11.5684;
  double _currentLng = 104.8906;
  String _selectedLocationName = 'SETEC Institute';
  String _selectedLocationAddress = 'Russian Federation Blvd, Toul Kork, Phnom Penh';

  bool _isGeocoding = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();

    // Check if arguments were passed from PaymentPage
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      if (args['name'] != null && (args['name'] as String).isNotEmpty) {
        _selectedLocationName = args['name'] as String;
      }
      if (args['address'] != null && (args['address'] as String).isNotEmpty) {
        _selectedLocationAddress = args['address'] as String;
      }
      if (args['latitude'] != null && args['latitude'] is double) {
        _currentLat = args['latitude'] as double;
      }
      if (args['longitude'] != null && args['longitude'] is double) {
        _currentLng = args['longitude'] as double;
      }
    }

    _locationController.text = _selectedLocationAddress;

    // Listen to sheet position changes to toggle button text
    _sheetController.addListener(() {
      final isNowExpanded = _sheetController.size > 0.55;
      if (isNowExpanded != _isExpanded) {
        setState(() {
          _isExpanded = isNowExpanded;
        });
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _locationController.dispose();
    _floorController.dispose();
    _instructionsController.dispose();
    _sheetController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _onCameraMove(CameraPosition position) {
    _currentLat = position.target.latitude;
    _currentLng = position.target.longitude;
  }

  void _onCameraIdle() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 600), () async {
      if (!mounted) return;
      setState(() {
        _isGeocoding = true;
      });

      final resolved = await MapLocationService.instance.reverseGeocode(
        _currentLat,
        _currentLng,
      );

      if (mounted) {
        setState(() {
          _selectedLocationAddress = resolved;
          _locationController.text = resolved;
          _isGeocoding = false;
        });
      }
    });
  }

  void _showLocationPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        List<LocationSearchResult> displayedLocations =
            List.from(MapLocationService.presetLocations);

        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.65,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  padding: const EdgeInsets.all(AppDimensions.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Drag handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: AppDimensions.md),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Text(
                        'Select or Search Location',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: AppDimensions.md),

                      // Search textfield
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Search landmark or street in Phnom Penh...',
                          prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                          filled: true,
                          fillColor: Theme.of(context).cardColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        onChanged: (query) async {
                          final results =
                              await MapLocationService.instance.searchPlaces(query);
                          setModalState(() {
                            displayedLocations = results;
                          });
                        },
                      ),
                      const SizedBox(height: AppDimensions.md),

                      // Location list
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: displayedLocations.length,
                          itemBuilder: (context, index) {
                            final loc = displayedLocations[index];
                            final isSelected =
                                (_currentLat - loc.latitude).abs() < 0.0008 &&
                                    (_currentLng - loc.longitude).abs() < 0.0008;

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isSelected
                                    ? AppColors.primary.withValues(alpha: 0.15)
                                    : Colors.grey.withValues(alpha: 0.1),
                                child: Icon(
                                  Icons.location_on,
                                  color: isSelected ? AppColors.primary : Colors.grey,
                                ),
                              ),
                              title: Text(
                                loc.name,
                                style: TextStyle(
                                  fontWeight:
                                      isSelected ? FontWeight.bold : FontWeight.w600,
                                  color: isSelected ? AppColors.primary : null,
                                ),
                              ),
                              subtitle: Text(
                                loc.address,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              trailing: isSelected
                                  ? const Icon(Icons.check_circle, color: AppColors.primary)
                                  : null,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppDimensions.radiusMd),
                              ),
                              onTap: () {
                                setState(() {
                                  _selectedLocationName = loc.name;
                                  _selectedLocationAddress = loc.address;
                                  _locationController.text = loc.address;
                                  _currentLat = loc.latitude;
                                  _currentLng = loc.longitude;
                                });
                                _mapController?.animateCamera(
                                  CameraUpdate.newLatLngZoom(
                                    LatLng(loc.latitude, loc.longitude),
                                    16.5,
                                  ),
                                );
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _onSave() {
    Get.back(result: {
      'name': _selectedLocationName,
      'address': _selectedLocationAddress,
      'latitude': _currentLat,
      'longitude': _currentLng,
      'floor': _floorController.text,
      'instructions': _instructionsController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    const double minChildSize = 0.35;
    const double maxChildSize = 0.90;
    const double initialChildSize = 0.45;

    return Scaffold(
      body: Stack(
        children: [
          // â”€â”€ Full-screen Real Google Map â”€â”€
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(_currentLat, _currentLng),
                zoom: 16.0,
              ),
              mapType: _currentMapType,
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              compassEnabled: true,
              mapToolbarEnabled: false,
              onMapCreated: (controller) {
                _mapController = controller;
              },
              onCameraMove: _onCameraMove,
              onCameraIdle: _onCameraIdle,
              onTap: (latLng) {
                _mapController?.animateCamera(
                  CameraUpdate.newLatLng(latLng),
                );
              },
            ),
          ),

          // â”€â”€ Fixed Center Pin with Location Name Bubble â”€â”€
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).size.height * 0.25,
            child: Center(
              child: IgnorePointer(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isGeocoding) ...[
                            const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Locating...',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: AppColors.primary,
                              ),
                            ),
                          ] else ...[
                            Icon(Icons.location_on, size: 14, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text(
                              _selectedLocationName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 46,
                    ),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Top Floating Controls ──
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 14,
            child: PointerInterceptor(
              child: Material(
                elevation: 4,
                shape: const CircleBorder(),
                color: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Get.back(),
                ),
              ),
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 14,
            child: PointerInterceptor(
              child: Column(
                children: [
                  // Toggle Map Type (Normal / Satellite)
                  FloatingActionButton.small(
                    heroTag: 'map_type_btn',
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    onPressed: () {
                      setState(() {
                        _currentMapType = _currentMapType == MapType.normal
                            ? MapType.satellite
                            : MapType.normal;
                      });
                    },
                    child: Icon(
                      _currentMapType == MapType.normal
                          ? Icons.satellite_alt_outlined
                          : Icons.map_outlined,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Re-center on Phnom Penh / Selected position
                  FloatingActionButton.small(
                    heroTag: 'recenter_btn',
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    onPressed: () {
                      _mapController?.animateCamera(
                        CameraUpdate.newLatLngZoom(
                          LatLng(_currentLat, _currentLng),
                          16.0,
                        ),
                      );
                    },
                    child: const Icon(Icons.my_location),
                  ),
                ],
              ),
            ),
          ),

          // ── Draggable Bottom Sheet ──
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: initialChildSize,
            minChildSize: minChildSize,
            maxChildSize: maxChildSize,
            builder: (context, scrollController) {
              return PointerInterceptor(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 18,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppDimensions.lg),
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: AppDimensions.lg),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // â”€â”€ Location TextField â”€â”€
                    TextField(
                      controller: _locationController,
                      readOnly: true,
                      onTap: _showLocationPicker,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.map_outlined, color: AppColors.primary),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                          onPressed: _showLocationPicker,
                        ),
                        hintText: 'Delivery address',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.md),

                    // â”€â”€ Floor TextField â”€â”€
                    TextField(
                      controller: _floorController,
                      decoration: InputDecoration(
                        hintText: 'Floor / Apartment / Unit (optional)',
                        prefixIcon: const Icon(Icons.layers_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.md),

                    // â”€â”€ Delivery Instructions TextField â”€â”€
                    TextField(
                      controller: _instructionsController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Delivery instructions (e.g. leave at the front door)',
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 40),
                          child: Icon(Icons.note_outlined),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.xl),

                    // â”€â”€ Dynamic Button â”€â”€
                    // Scroll UP (expanded) â†’ "Save and Continue"
                    // Scroll DOWN (collapsed) â†’ "Apply Changes"
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _onSave,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                          ),
                        ),
                        child: Text(
                          _isExpanded ? 'Save and Continue' : 'Apply Changes',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.lg),
                  ],
                ),
              ),
            );
          },
          ),
        ],
      ),
    );
  }
}
