import 'dart:typed_data';

/// Fallback stub for non-IO targets (e.g., Flutter Web).
Future<Uint8List> fetchResilientImageBytes(
  String url, {
  required String cacheKey,
  Map<String, String>? headers,
  void Function(int cumulative, int? total)? onBytesReceived,
}) {
  throw UnsupportedError(
    'Resilient IO image fetching is only supported on dart:io platforms.',
  );
}

void clearResilientImageCache() {}
