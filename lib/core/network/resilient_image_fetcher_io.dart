import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import '../services/cloudflare_r2_service.dart';

/// Maximum concurrent image downloads to avoid saturating emulator NAT or
/// high-latency mobile connections at startup.
const int _maxConcurrentDownloads = 3;

/// Maximum attempts per image fetch before propagating a network error.
const int _maxAttempts = 4;

/// In-memory LRU byte cache limit.
const int _maxCachedEntries = 64;
const int _maxCachedBytes = 24 * 1024 * 1024; // 24 MB

final LinkedHashMap<String, Uint8List> _byteCache = LinkedHashMap();
int _cachedByteTotal = 0;

final Map<String, Future<Uint8List>> _inFlight = {};
final Queue<Completer<void>> _waitQueue = Queue<Completer<void>>();
int _activeDownloads = 0;

final Map<String, ({List<InternetAddress> addresses, DateTime expiresAt})>
    _dnsIpv4Cache = {};
int _ipRoundRobin = 0;

final HttpClient _sharedClient = _buildHardenedClient();

HttpClient _buildHardenedClient() {
  return HttpClient()
    ..autoUncompress = false
    ..connectionTimeout = const Duration(seconds: 15)
    ..idleTimeout = const Duration(seconds: 4)
    ..maxConnectionsPerHost = _maxConcurrentDownloads
    ..connectionFactory = _ipv4FirstConnectionFactory;
}

Future<ConnectionTask<Socket>> _ipv4FirstConnectionFactory(
  Uri uri,
  String? proxyHost,
  int? proxyPort,
) async {
  if (proxyHost != null) {
    return Socket.startConnect(
      proxyHost,
      proxyPort ?? (uri.scheme == 'https' ? 443 : 80),
    );
  }

  final targetPort = uri.hasPort
      ? uri.port
      : (uri.scheme == 'https' ? 443 : 80);

  final ipv4Addresses = await _lookupIpv4Cached(uri.host);
  if (ipv4Addresses.isNotEmpty) {
    final target = ipv4Addresses[(_ipRoundRobin++) % ipv4Addresses.length];
    return uri.scheme == 'https'
        ? SecureSocket.startConnect(target, targetPort)
        : Socket.startConnect(target, targetPort);
  }

  return uri.scheme == 'https'
      ? SecureSocket.startConnect(uri.host, targetPort)
      : Socket.startConnect(uri.host, targetPort);
}

Future<List<InternetAddress>> _lookupIpv4Cached(String host) async {
  final parsedLiteral = InternetAddress.tryParse(host);
  if (parsedLiteral != null) {
    return [parsedLiteral];
  }

  final now = DateTime.now();
  final cached = _dnsIpv4Cache[host];
  if (cached != null && cached.expiresAt.isAfter(now)) {
    return cached.addresses;
  }

  try {
    final resolved = await InternetAddress.lookup(
      host,
      type: InternetAddressType.IPv4,
    ).timeout(const Duration(seconds: 5));
    if (resolved.isNotEmpty) {
      _dnsIpv4Cache[host] = (
        addresses: resolved,
        expiresAt: now.add(const Duration(seconds: 60)),
      );
      return resolved;
    }
  } catch (_) {
    // Fall back to system default dual-stack resolution (e.g. IPv6-only networks).
  }
  return const [];
}

/// Fetches image bytes with bounded concurrency, IPv4-first socket creation,
/// in-flight deduplication, in-memory byte caching, and transient error retries.
Future<Uint8List> fetchResilientImageBytes(
  String url, {
  required String cacheKey,
  Map<String, String>? headers,
  void Function(int cumulative, int? total)? onBytesReceived,
}) async {
  final cached = _getFromByteCache(cacheKey);
  if (cached != null) {
    return cached;
  }

  final existing = _inFlight[cacheKey];
  if (existing != null) {
    return existing;
  }

  final future = _runWithSlot(
    () => _fetchWithRetries(
      url,
      cacheKey: cacheKey,
      headers: headers,
      onBytesReceived: onBytesReceived,
    ),
  );
  _inFlight[cacheKey] = future;

  try {
    return await future;
  } finally {
    if (identical(_inFlight[cacheKey], future)) {
      _inFlight.remove(cacheKey);
    }
  }
}

void clearResilientImageCache() {
  _byteCache.clear();
  _cachedByteTotal = 0;
}

Uint8List? _getFromByteCache(String cacheKey) {
  final hit = _byteCache.remove(cacheKey);
  if (hit != null) {
    _byteCache[cacheKey] = hit;
  }
  return hit;
}

void _storeInByteCache(String cacheKey, Uint8List bytes) {
  if (bytes.lengthInBytes > _maxCachedBytes ~/ 2) {
    return;
  }

  final existing = _byteCache.remove(cacheKey);
  if (existing != null) {
    _cachedByteTotal -= existing.lengthInBytes;
  }

  _byteCache[cacheKey] = bytes;
  _cachedByteTotal += bytes.lengthInBytes;

  while (_byteCache.length > _maxCachedEntries ||
      _cachedByteTotal > _maxCachedBytes) {
    final oldestKey = _byteCache.keys.first;
    final removed = _byteCache.remove(oldestKey);
    if (removed != null) {
      _cachedByteTotal -= removed.lengthInBytes;
    }
  }
}

Future<T> _runWithSlot<T>(Future<T> Function() task) async {
  if (_activeDownloads >= _maxConcurrentDownloads) {
    final completer = Completer<void>();
    _waitQueue.add(completer);
    await completer.future;
  }
  _activeDownloads++;
  try {
    return await task();
  } finally {
    _activeDownloads--;
    if (_waitQueue.isNotEmpty) {
      _waitQueue.removeFirst().complete();
    }
  }
}

HttpClient _resolveHttpClient() {
  HttpClient? debugClient;
  assert(() {
    if (debugNetworkImageHttpClientProvider != null) {
      debugClient = debugNetworkImageHttpClientProvider!();
    }
    return true;
  }());
  if (debugClient != null) {
    return debugClient!;
  }
  if (HttpOverrides.current != null) {
    return HttpClient()..autoUncompress = false;
  }
  return _sharedClient;
}

Future<Uint8List> _fetchWithRetries(
  String url, {
  required String cacheKey,
  Map<String, String>? headers,
  void Function(int cumulative, int? total)? onBytesReceived,
}) async {
  Object? lastError;
  StackTrace? lastStackTrace;
  var activeUri = Uri.base.resolve(url);

  for (var attempt = 0; attempt < _maxAttempts; attempt++) {
    final client = _resolveHttpClient();

    try {
      final request = await client
          .getUrl(activeUri)
          .timeout(const Duration(seconds: 15));

      headers?.forEach((name, value) {
        request.headers.add(name, value);
      });

      // Force a fresh socket on retries so stale keep-alive/NAT connections
      // are bypassed and rotated across edge IPv4 addresses.
      if (attempt > 0) {
        request.persistentConnection = false;
        request.headers.set(HttpHeaders.connectionHeader, 'close');
      }

      final response = await request.close().timeout(
        const Duration(seconds: 25),
      );

      if (response.statusCode != HttpStatus.ok) {
        await response.drain<List<int>>(<int>[]);

        if (response.statusCode == HttpStatus.forbidden &&
            attempt == 0 &&
            activeUri.host.contains('r2.cloudflarestorage.com')) {
          final refreshed = CloudflareR2Service.resolveImageUrl(
            '${activeUri.scheme}://${activeUri.host}${activeUri.path}',
          );
          if (refreshed != null && refreshed != activeUri.toString()) {
            activeUri = Uri.parse(refreshed);
            continue;
          }
        }

        if (!_isRetryableStatus(response.statusCode) ||
            attempt == _maxAttempts - 1) {
          throw NetworkImageLoadException(
            statusCode: response.statusCode,
            uri: activeUri,
          );
        }

        lastError = NetworkImageLoadException(
          statusCode: response.statusCode,
          uri: activeUri,
        );
        lastStackTrace = StackTrace.current;
      } else {
        final Uint8List bytes = await consolidateHttpClientResponseBytes(
          response,
          onBytesReceived: onBytesReceived,
        ).timeout(const Duration(seconds: 25));

        if (bytes.isEmpty) {
          throw Exception('ResilientNetworkImage is an empty file: $activeUri');
        }

        _storeInByteCache(cacheKey, bytes);
        return bytes;
      }
    } catch (e, st) {
      if (!_isRetryableError(e) || attempt == _maxAttempts - 1) {
        rethrow;
      }
      lastError = e;
      lastStackTrace = st;
    }

    if (attempt < _maxAttempts - 1) {
      await Future<void>.delayed(_backoffForAttempt(attempt));
    }
  }

  Error.throwWithStackTrace(
    lastError ?? Exception('Failed to load image: $activeUri'),
    lastStackTrace ?? StackTrace.current,
  );
}

bool _isRetryableStatus(int statusCode) {
  return statusCode == HttpStatus.requestTimeout ||
      statusCode == HttpStatus.tooManyRequests ||
      (statusCode >= 500 && statusCode < 600);
}

bool _isRetryableError(Object error) {
  return error is SocketException ||
      error is HandshakeException ||
      error is HttpException ||
      error is TimeoutException ||
      error is TlsException;
}

Duration _backoffForAttempt(int attempt) {
  return switch (attempt) {
    0 => const Duration(milliseconds: 200),
    1 => const Duration(milliseconds: 500),
    _ => const Duration(milliseconds: 1000),
  };
}
