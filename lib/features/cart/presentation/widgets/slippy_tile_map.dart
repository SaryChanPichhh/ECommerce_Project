import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../../core/services/map_location_service.dart';
import '../../../../core/widgets/app_network_image.dart';

enum TileMapSource {
  osm,
  satellite,
}

/// A lightweight, interactive slippy tile map canvas.
///
/// Seamlessly renders OpenStreetMap or Esri World Imagery satellite tiles
/// with smooth panning gestures, zoom controls, and coordinate calculations.
class SlippyTileMap extends StatelessWidget {
  final double latitude;
  final double longitude;
  final int zoom;
  final TileMapSource source;
  final double verticalCenterOffset;
  final void Function(double dLat, double dLng)? onPanDelta;
  final VoidCallback? onPanEnd;

  const SlippyTileMap({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.zoom,
    this.source = TileMapSource.osm,
    this.verticalCenterOffset = -0.12,
    this.onPanDelta,
    this.onPanEnd,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        final screenCenterX = w / 2.0;
        final screenCenterY = h * (0.5 + verticalCenterOffset);

        final n = 1 << zoom;
        final worldSize = 256.0 * n;

        final xWorld = (longitude + 180.0) / 360.0 * worldSize;
        final latClamped = latitude.clamp(-85.0511, 85.0511);
        final latRad = latClamped * math.pi / 180.0;
        final yWorld = (1.0 -
                math.log(math.tan(latRad) + 1.0 / math.cos(latRad)) / math.pi) /
            2.0 *
            worldSize;

        final x0 = xWorld - screenCenterX;
        final y0 = yWorld - screenCenterY;

        final minTileX = (x0 / 256.0).floor() - 1;
        final maxTileX = ((x0 + w) / 256.0).floor() + 1;
        final minTileY = (y0 / 256.0).floor() - 1;
        final maxTileY = ((y0 + h) / 256.0).floor() + 1;

        final tiles = <Widget>[];

        for (int tx = minTileX; tx <= maxTileX; tx++) {
          final wrappedTx = ((tx % n) + n) % n;
          for (int ty = minTileY; ty <= maxTileY; ty++) {
            if (ty < 0 || ty >= n) continue;

            final tileLeft = tx * 256.0 - x0;
            final tileTop = ty * 256.0 - y0;

            final tileUrl = source == TileMapSource.satellite
                ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/$zoom/$ty/$wrappedTx'
                : 'https://tile.openstreetmap.org/$zoom/$wrappedTx/$ty.png';

            tiles.add(
              Positioned(
                key: ValueKey('$source-$zoom-$wrappedTx-$ty'),
                left: tileLeft,
                top: tileTop,
                width: 256,
                height: 256,
                child: AppNetworkImage(
                  imageUrl: tileUrl,
                  fit: BoxFit.cover,
                  headers: MapLocationService.osmHeaders,
                  fallbackIcon: Icons.map_outlined,
                  backgroundColor: const Color(0xFFECE6DA),
                ),
              ),
            );
          }
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanUpdate: (details) {
            if (onPanDelta == null) return;
            final dLng = -details.delta.dx / worldSize * 360.0;
            final cosLat = math.cos(latRad);
            final dLat = details.delta.dy / worldSize * 360.0 * cosLat;
            onPanDelta!(dLat, dLng);
          },
          onPanEnd: (_) => onPanEnd?.call(),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: tiles,
          ),
        );
      },
    );
  }
}
