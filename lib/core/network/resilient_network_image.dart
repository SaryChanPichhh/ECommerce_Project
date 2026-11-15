import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import '../services/cloudflare_r2_service.dart';
import 'resilient_image_fetcher_stub.dart'
    if (dart.library.io) 'resilient_image_fetcher_io.dart'
    as fetcher;

/// Network [ImageProvider] designed for unreliable mobile networks, emulators,
/// and Cloudflare R2 presigned URLs.
///
/// Uses bounded concurrency, IPv4-first connections, in-flight deduplication,
/// normalized R2 cache keys, and automatic retries for transient socket resets.
@immutable
class ResilientNetworkImage extends ImageProvider<ResilientNetworkImage> {
  final String url;
  final double scale;
  final Map<String, String>? headers;

  const ResilientNetworkImage(
    this.url, {
    this.scale = 1.0,
    this.headers,
  });

  String get cacheKey => CloudflareR2Service.cacheKeyForUrl(url);

  @override
  Future<ResilientNetworkImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<ResilientNetworkImage>(this);
  }

  @override
  ImageStreamCompleter loadImage(
    ResilientNetworkImage key,
    ImageDecoderCallback decode,
  ) {
    final chunkEvents = StreamController<ImageChunkEvent>();

    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, chunkEvents, decode: decode),
      chunkEvents: chunkEvents.stream,
      scale: key.scale,
      debugLabel: key.url,
      informationCollector: () => <DiagnosticsNode>[
        DiagnosticsProperty<ImageProvider>('Image provider', this),
        DiagnosticsProperty<ResilientNetworkImage>('Image key', key),
      ],
    );
  }

  Future<ui.Codec> _loadAsync(
    ResilientNetworkImage key,
    StreamController<ImageChunkEvent> chunkEvents, {
    required ImageDecoderCallback decode,
  }) async {
    try {
      final bytes = await fetcher.fetchResilientImageBytes(
        key.url,
        cacheKey: key.cacheKey,
        headers: key.headers,
        onBytesReceived: (cumulative, total) {
          if (!chunkEvents.isClosed) {
            chunkEvents.add(
              ImageChunkEvent(
                cumulativeBytesLoaded: cumulative,
                expectedTotalBytes: total,
              ),
            );
          }
        },
      );

      final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
      return decode(buffer);
    } catch (_) {
      scheduleMicrotask(() {
        PaintingBinding.instance.imageCache.evict(key);
      });
      rethrow;
    } finally {
      await chunkEvents.close();
    }
  }

  static void clearCache() => fetcher.clearResilientImageCache();

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is ResilientNetworkImage &&
        other.cacheKey == cacheKey &&
        other.scale == scale &&
        mapEquals(other.headers, headers);
  }

  @override
  int get hashCode {
    final sortedHeaders = headers == null
        ? null
        : (headers!.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));
    return Object.hash(
      cacheKey,
      scale,
      sortedHeaders == null
          ? null
          : Object.hashAll(
              sortedHeaders.map((e) => Object.hash(e.key, e.value)),
            ),
    );
  }

  @override
  String toString() =>
      '${objectRuntimeType(this, 'ResilientNetworkImage')}("$url", scale: ${scale.toStringAsFixed(1)})';
}
