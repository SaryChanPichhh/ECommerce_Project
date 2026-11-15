import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

import '../../../../core/services/map_location_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../widgets/slippy_tile_map.dart';

enum MapViewMode {
  osm,
  satellite,
  google,
}

class EditAddressPage extends StatefulWidget {
  const EditAddressPage({super.key});

  @override
  State<EditAddressPage> createState() => _EditAddressPageState();
}

class _EditAddressPageState extends State<EditAddressPage> {
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _floorController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();

  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  bool _isExpanded = false;

  GoogleMapController? _mapController;
  final MapType _currentMapType = MapType.normal;
  MapViewMode _viewMode = MapViewMode.osm;
  int _zoomLevel = 16;

  double _currentLat = 11.5684;
  double _currentLng = 104.8906;
  String _selectedLocationName = 'SETEC Institute';
  String _selectedLocationAddress =
      'Russian Federation Blvd, Toul Kork, Phnom Penh';

  bool _isGeocoding = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();

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
    final parentTheme = Theme.of(context);
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
        final secondaryColor =
            parentTheme.colorScheme.onSurface.withValues(alpha: 0.62);

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
                    color: parentTheme.scaffoldBackgroundColor,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  padding: const EdgeInsets.all(AppDimensions.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: AppDimensions.md),
                          decoration: BoxDecoration(
                            color: parentTheme.dividerColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Text(
                        'select_location'.tr,
                        style: parentTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.md),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'search_location_hint'.tr,
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AppColors.primary,
                          ),
                          filled: true,
                          fillColor: parentTheme.cardColor,
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppDimensions.radiusLg),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        onChanged: (query) async {
                          final results = await MapLocationService.instance
                              .searchPlaces(query);
                          setModalState(() {
                            displayedLocations = results;
                          });
                        },
                      ),
                      const SizedBox(height: AppDimensions.md),
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
                                    : parentTheme.colorScheme.onSurface
                                        .withValues(alpha: 0.08),
                                child: Icon(
                                  Icons.location_on,
                                  color: isSelected
                                      ? AppColors.primary
                                      : secondaryColor,
                                ),
                              ),
                              title: Text(
                                loc.name,
                                style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                  color: isSelected ? AppColors.primary : null,
                                ),
                              ),
                              subtitle: Text(
                                loc.address,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: secondaryColor,
                                ),
                              ),
                              trailing: isSelected
                                  ? const Icon(
                                      Icons.check_circle,
                                      color: AppColors.primary,
                                    )
                                  : null,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusMd,
                                ),
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
    final theme = Theme.of(context);
    const double minChildSize = 0.35;
    const double maxChildSize = 0.90;
    const double initialChildSize = 0.45;

    return Scaffold(
      body: Stack(
        children: [
          // Full-screen Map View (SlippyTileMap or GoogleMap)
          Positioned.fill(
            child: _viewMode == MapViewMode.google
                ? GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(_currentLat, _currentLng),
                      zoom: _zoomLevel.toDouble(),
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
                      setState(() {
                        _currentLat = latLng.latitude;
                        _currentLng = latLng.longitude;
                      });
                      _mapController?.animateCamera(
                        CameraUpdate.newLatLng(latLng),
                      );
                      _onCameraIdle();
                    },
                  )
                : SlippyTileMap(
                    latitude: _currentLat,
                    longitude: _currentLng,
                    zoom: _zoomLevel,
                    source: _viewMode == MapViewMode.satellite
                        ? TileMapSource.satellite
                        : TileMapSource.osm,
                    verticalCenterOffset: -0.12,
                    onPanDelta: (dLat, dLng) {
                      setState(() {
                        _currentLat = (_currentLat + dLat).clamp(-85.0, 85.0);
                        _currentLng =
                            ((_currentLng + dLng + 180.0) % 360.0) - 180.0;
                      });
                    },
                    onPanEnd: _onCameraIdle,
                  ),
          ),

          // Fixed Center Pin with Location Name Bubble
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.16),
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
                            Text(
                              'locating'.tr,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: AppColors.primary,
                              ),
                            ),
                          ] else ...[
                            const Icon(
                              Icons.location_on,
                              size: 14,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _selectedLocationName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.location_pin,
                      color: AppColors.error,
                      size: 46,
                    ),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.22),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Top Floating Controls
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 14,
            child: PointerInterceptor(
              child: Material(
                elevation: 4,
                shape: const CircleBorder(),
                color: theme.cardColor,
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: theme.colorScheme.onSurface,
                  ),
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
                  // Map Source Selector (OSM, Satellite, Google Maps)
                  PopupMenuButton<MapViewMode>(
                    tooltip: 'map_source'.tr,
                    color: theme.cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusLg),
                    ),
                    icon: Material(
                      elevation: 4,
                      shape: const CircleBorder(),
                      color: theme.cardColor,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          switch (_viewMode) {
                            MapViewMode.osm => Icons.map_outlined,
                            MapViewMode.satellite =>
                              Icons.satellite_alt_outlined,
                            MapViewMode.google => Icons.public_rounded,
                          },
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                    ),
                    onSelected: (mode) {
                      setState(() {
                        _viewMode = mode;
                      });
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: MapViewMode.osm,
                        child: Row(
                          children: [
                            Icon(
                              Icons.map_outlined,
                              color: _viewMode == MapViewMode.osm
                                  ? AppColors.primary
                                  : null,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'osm_map'.tr,
                              style: TextStyle(
                                fontWeight: _viewMode == MapViewMode.osm
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: _viewMode == MapViewMode.osm
                                    ? AppColors.primary
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: MapViewMode.satellite,
                        child: Row(
                          children: [
                            Icon(
                              Icons.satellite_alt_outlined,
                              color: _viewMode == MapViewMode.satellite
                                  ? AppColors.primary
                                  : null,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'satellite_map'.tr,
                              style: TextStyle(
                                fontWeight: _viewMode == MapViewMode.satellite
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: _viewMode == MapViewMode.satellite
                                    ? AppColors.primary
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: MapViewMode.google,
                        child: Row(
                          children: [
                            Icon(
                              Icons.public_rounded,
                              color: _viewMode == MapViewMode.google
                                  ? AppColors.primary
                                  : null,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'google_map'.tr,
                              style: TextStyle(
                                fontWeight: _viewMode == MapViewMode.google
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: _viewMode == MapViewMode.google
                                    ? AppColors.primary
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Zoom In Button
                  FloatingActionButton.small(
                    heroTag: 'zoom_in_btn',
                    tooltip: 'zoom_in'.tr,
                    backgroundColor: theme.cardColor,
                    foregroundColor: theme.colorScheme.onSurface,
                    onPressed: () {
                      setState(() {
                        _zoomLevel = (_zoomLevel + 1).clamp(12, 18);
                      });
                      _mapController?.animateCamera(CameraUpdate.zoomIn());
                    },
                    child: const Icon(Icons.add, size: 20),
                  ),
                  const SizedBox(height: 8),
                  // Zoom Out Button
                  FloatingActionButton.small(
                    heroTag: 'zoom_out_btn',
                    tooltip: 'zoom_out'.tr,
                    backgroundColor: theme.cardColor,
                    foregroundColor: theme.colorScheme.onSurface,
                    onPressed: () {
                      setState(() {
                        _zoomLevel = (_zoomLevel - 1).clamp(12, 18);
                      });
                      _mapController?.animateCamera(CameraUpdate.zoomOut());
                    },
                    child: const Icon(Icons.remove, size: 20),
                  ),
                  const SizedBox(height: 8),
                  // Recenter Button
                  FloatingActionButton.small(
                    heroTag: 'recenter_btn',
                    tooltip: 'recenter'.tr,
                    backgroundColor: theme.cardColor,
                    foregroundColor: AppColors.primary,
                    onPressed: () {
                      setState(() {
                        _currentLat = 11.5684;
                        _currentLng = 104.8906;
                        _zoomLevel = 16;
                      });
                      _mapController?.animateCamera(
                        CameraUpdate.newLatLngZoom(
                          const LatLng(11.5684, 104.8906),
                          16.0,
                        ),
                      );
                      _onCameraIdle();
                    },
                    child: const Icon(Icons.my_location, size: 20),
                  ),
                ],
              ),
            ),
          ),

          // Draggable Bottom Sheet
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: initialChildSize,
            minChildSize: minChildSize,
            maxChildSize: maxChildSize,
            builder: (context, scrollController) {
              return PointerInterceptor(
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.14),
                        blurRadius: 18,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(AppDimensions.lg),
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: AppDimensions.lg),
                          decoration: BoxDecoration(
                            color: theme.dividerColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      TextField(
                        controller: _locationController,
                        readOnly: true,
                        onTap: _showLocationPicker,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.map_outlined,
                            color: AppColors.primary,
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: AppColors.primary,
                            ),
                            onPressed: _showLocationPicker,
                          ),
                          hintText: 'delivery_address'.tr,
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppDimensions.radiusLg),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.md),
                      TextField(
                        controller: _floorController,
                        decoration: InputDecoration(
                          hintText: 'floor_optional'.tr,
                          prefixIcon: const Icon(Icons.layers_outlined),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppDimensions.radiusLg),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.md),
                      TextField(
                        controller: _instructionsController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'delivery_instructions_hint'.tr,
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(bottom: 40),
                            child: Icon(Icons.note_outlined),
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppDimensions.radiusLg),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.xl),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _onSave,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppDimensions.radiusLg),
                            ),
                          ),
                          child: Text(
                            _isExpanded
                                ? 'save_and_continue'.tr
                                : 'apply_changes'.tr,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
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
