import 'dart:math' as math;
import 'package:dio/dio.dart';
import '../constants/app_constants.dart';

class LocationSearchResult {
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  const LocationSearchResult({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });
}

class MapLocationService {
  MapLocationService._();
  static final MapLocationService instance = MapLocationService._();

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 6),
      receiveTimeout: const Duration(seconds: 6),
      headers: {
        'User-Agent': 'FlutterMapApp/1.0',
      },
    ),
  );

  /// Standard OpenStreetMap tile User-Agent headers to comply with OSM usage policy.
  static const Map<String, String> osmHeaders = {
    'User-Agent': 'FinalProjectECommerce/1.0 (Flutter; Android)',
  };

  /// Calculates slippy map tile X index from longitude and zoom.
  static int lon2tileX(double lon, int zoom) {
    final n = 1 << zoom;
    return ((lon + 180.0) / 360.0 * n).floor().clamp(0, n - 1);
  }

  /// Calculates slippy map tile Y index from latitude and zoom.
  static int lat2tileY(double lat, int zoom) {
    final n = 1 << zoom;
    final latRad = lat.clamp(-85.0511, 85.0511) * math.pi / 180.0;
    return ((1.0 - math.log(math.tan(latRad) + 1.0 / math.cos(latRad)) / math.pi) / 2.0 * n)
        .floor()
        .clamp(0, n - 1);
  }

  /// Calculates longitude from slippy map tile X index and zoom.
  static double tileX2lon(num x, int zoom) {
    return x / (1 << zoom) * 360.0 - 180.0;
  }

  /// Calculates latitude from slippy map tile Y index and zoom.
  static double tileY2lat(num y, int zoom) {
    final n = math.pi - 2.0 * math.pi * y / (1 << zoom);
    return 180.0 / math.pi * math.atan(0.5 * (math.exp(n) - math.exp(-n)));
  }

  /// Returns standard OpenStreetMap slippy tile URL for (lat, lng) at [zoom].
  static String getOsmTileUrl(double lat, double lng, {int zoom = 15}) {
    final x = lon2tileX(lng, zoom);
    final y = lat2tileY(lat, zoom);
    return 'https://tile.openstreetmap.org/$zoom/$x/$y.png';
  }

  /// Returns Esri World Imagery satellite tile URL for (lat, lng) at [zoom].
  static String getSatelliteTileUrl(double lat, double lng, {int zoom = 15}) {
    final x = lon2tileX(lng, zoom);
    final y = lat2tileY(lat, zoom);
    return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/$zoom/$y/$x';
  }

  /// Preset landmarks in Phnom Penh, Cambodia
  static const List<LocationSearchResult> presetLocations = [
    LocationSearchResult(
      name: 'Home',
      address: '123 Russian Federation Blvd, Phnom Penh, Cambodia',
      latitude: 11.5621,
      longitude: 104.8872,
    ),
    LocationSearchResult(
      name: 'SETEC Institute',
      address: 'Russian Federation Blvd, Toul Kork, Phnom Penh',
      latitude: 11.5684,
      longitude: 104.8906,
    ),
    LocationSearchResult(
      name: 'Office (Canadia Tower)',
      address: '315 Ang Duong St, Monivong Blvd, Phnom Penh',
      latitude: 11.5727,
      longitude: 104.9213,
    ),
    LocationSearchResult(
      name: 'AEON Mall Phnom Penh',
      address: '132 Samdach Sothearos Blvd, Sangkat Tonle Bassac, Phnom Penh',
      latitude: 11.5478,
      longitude: 104.9351,
    ),
    LocationSearchResult(
      name: 'AEON Mall Sen Sok',
      address: 'St. 1003, Bayab Village, Sangkat Phnom Penh Thmey, Sen Sok',
      latitude: 11.5977,
      longitude: 104.8809,
    ),
    LocationSearchResult(
      name: 'Independence Monument',
      address: 'Preah Norodom Blvd, Sangkat Boeung Keng Kang I, Phnom Penh',
      latitude: 11.5564,
      longitude: 104.9282,
    ),
    LocationSearchResult(
      name: 'Coffee Shop (BKK1)',
      address: 'Corner St 57 & St 306, BKK1, Phnom Penh',
      latitude: 11.5512,
      longitude: 104.9245,
    ),
    LocationSearchResult(
      name: 'Central Market (Phsar Thmey)',
      address: 'Calmette St, Sangkat Phsar Thmey 1, Phnom Penh',
      latitude: 11.5696,
      longitude: 104.9211,
    ),
    LocationSearchResult(
      name: 'Russian Market (Toul Tom Poung)',
      address: 'St 163, Sangkat Toul Tom Poung 1, Khan Chamkarmon, Phnom Penh',
      latitude: 11.5407,
      longitude: 104.9149,
    ),
  ];

  /// Reverse geocode coordinates to a readable street address.
  /// Tries Google Geocoding API first using the user's Google Maps key.
  /// Automatically falls back to OpenStreetMap Nominatim if Google API is disabled/unrestricted.
  Future<String> reverseGeocode(double latitude, double longitude) async {
    // 1. Try Google Geocoding API
    if (AppConstants.googleMapsApiKey.isNotEmpty) {
      try {
        final googleUrl =
            'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=${AppConstants.googleMapsApiKey}';
        final response = await _dio.get(googleUrl);
        if (response.statusCode == 200 && response.data is Map) {
          final status = response.data['status'];
          final results = response.data['results'] as List?;
          if (status == 'OK' && results != null && results.isNotEmpty) {
            final formatted = results[0]['formatted_address'] as String?;
            if (formatted != null && formatted.isNotEmpty) {
              return formatted;
            }
          }
        }
      } catch (_) {
        // Fallback to OpenStreetMap
      }
    }

    // 2. Fallback to OpenStreetMap Nominatim
    try {
      final osmUrl =
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude&zoom=18&addressdetails=1';
      final response = await _dio.get(osmUrl);
      if (response.statusCode == 200 && response.data is Map) {
        final displayName = response.data['display_name'] as String?;
        if (displayName != null && displayName.isNotEmpty) {
          // Format neatly (first 3 parts if long)
          final parts = displayName.split(', ');
          if (parts.length > 4) {
            return '${parts.take(3).join(', ')}, Phnom Penh';
          }
          return displayName;
        }
      }
    } catch (_) {
      // Fallback
    }

    // 3. Coordinate fallback
    return 'Lat: ${latitude.toStringAsFixed(5)}, Lng: ${longitude.toStringAsFixed(5)}, Phnom Penh';
  }

  /// Search places by keyword query.
  Future<List<LocationSearchResult>> searchPlaces(String query) async {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) return presetLocations;

    // First search in local presets
    final localMatches = presetLocations.where((p) {
      return p.name.toLowerCase().contains(cleanQuery) ||
          p.address.toLowerCase().contains(cleanQuery);
    }).toList();

    // Query Nominatim for live suggestions
    try {
      final osmUrl =
          'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&countrycodes=kh&limit=5';
      final response = await _dio.get(osmUrl);
      if (response.statusCode == 200 && response.data is List) {
        final results = <LocationSearchResult>[];
        for (final item in response.data) {
          final lat = double.tryParse(item['lat']?.toString() ?? '');
          final lon = double.tryParse(item['lon']?.toString() ?? '');
          final name = (item['display_name'] as String? ?? '').split(',').first;
          final address = item['display_name'] as String? ?? '';
          if (lat != null && lon != null) {
            results.add(
              LocationSearchResult(
                name: name.isEmpty ? query : name,
                address: address,
                latitude: lat,
                longitude: lon,
              ),
            );
          }
        }
        if (results.isNotEmpty) {
          // Combine local matches + remote results, avoiding duplicates
          final all = [...localMatches];
          for (final r in results) {
            if (!all.any((e) =>
                (e.latitude - r.latitude).abs() < 0.001 &&
                (e.longitude - r.longitude).abs() < 0.001)) {
              all.add(r);
            }
          }
          return all;
        }
      }
    } catch (_) {
      // Ignore network search errors, fallback to local
    }

    return localMatches.isNotEmpty ? localMatches : presetLocations;
  }
}
