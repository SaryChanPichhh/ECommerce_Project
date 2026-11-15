import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:final_project/core/localization/app_translations.dart';
import 'package:final_project/core/network/resilient_image_fetcher_io.dart';
import 'package:final_project/core/network/resilient_network_image.dart';
import 'package:final_project/core/services/cloudflare_r2_service.dart';
import 'package:final_project/core/services/map_location_service.dart';
import 'package:final_project/core/theme/app_theme.dart';
import 'package:final_project/core/widgets/app_network_image.dart';
import 'package:final_project/features/cart/presentation/widgets/aba_logo.dart';
import 'package:final_project/features/products/data/models/product_model.dart';

void main() {
  group('CloudflareR2Service.resolveImageUrl', () {
    test('returns null for blank values and preserves assets and external URLs', () {
      expect(CloudflareR2Service.resolveImageUrl(null), isNull);
      expect(CloudflareR2Service.resolveImageUrl('   '), isNull);
      expect(
        CloudflareR2Service.resolveImageUrl('assets/images/profile.jpg'),
        equals('assets/images/profile.jpg'),
      );
      expect(
        CloudflareR2Service.resolveImageUrl('https://images.unsplash.com/photo.jpg'),
        equals('https://images.unsplash.com/photo.jpg'),
      );
    });

    test('presigns unsigned R2 URLs and relative object keys', () {
      final fromRelative = CloudflareR2Service.resolveImageUrl(
        'products/macbook-pro-14-m4.jpg',
      );
      expect(fromRelative, isNotNull);
      expect(fromRelative, contains('r2.cloudflarestorage.com'));
      expect(fromRelative, contains('X-Amz-Algorithm=AWS4-HMAC-SHA256'));
      expect(fromRelative, contains('X-Amz-Signature='));

      final fromUnsignedR2 = CloudflareR2Service.resolveImageUrl(
        'https://65b56bbba6f4c9c7870520709fd7a165.r2.cloudflarestorage.com/ecomstorage/categories/consumer-electronics.jpg',
      );
      expect(fromUnsignedR2, isNotNull);
      expect(fromUnsignedR2, contains('X-Amz-Signature='));
      expect(fromUnsignedR2, contains('categories/consumer-electronics.jpg'));
    });

    test('resigns expired R2 presigned URLs', () {
      const expiredUrl =
          'https://65b56bbba6f4c9c7870520709fd7a165.r2.cloudflarestorage.com/ecomstorage/products/test.jpg'
          '?X-Amz-Algorithm=AWS4-HMAC-SHA256'
          '&X-Amz-Credential=abc%2F20200101%2Fauto%2Fs3%2Faws4_request'
          '&X-Amz-Date=20200101T000000Z'
          '&X-Amz-Expires=3600'
          '&X-Amz-SignedHeaders=host'
          '&X-Amz-Signature=deadbeef';

      final resolved = CloudflareR2Service.resolveImageUrl(expiredUrl);
      expect(resolved, isNotNull);
      expect(resolved, isNot(equals(expiredUrl)));
      expect(resolved, contains('X-Amz-Expires=604800'));
    });

    test('memoizes presigned URLs and normalizes R2 cache keys', () {
      final first = CloudflareR2Service.resolveImageUrl('stores/tech-banner.jpg');
      final second = CloudflareR2Service.resolveImageUrl('stores/tech-banner.jpg');
      expect(first, isNotNull);
      expect(second, equals(first));

      const urlA =
          'https://65b56bbba6f4c9c7870520709fd7a165.r2.cloudflarestorage.com/ecomstorage/stores/tech-banner.jpg?X-Amz-Date=20261108T100000Z';
      const urlB =
          'https://65b56bbba6f4c9c7870520709fd7a165.r2.cloudflarestorage.com/ecomstorage/stores/tech-banner.jpg?X-Amz-Date=20261108T110000Z';
      expect(
        CloudflareR2Service.cacheKeyForUrl(urlA),
        equals(CloudflareR2Service.cacheKeyForUrl(urlB)),
      );
      expect(const ResilientNetworkImage(urlA), equals(const ResilientNetworkImage(urlB)));
    });
  });

  group('ResilientNetworkImage fetcher', () {
    tearDown(ResilientNetworkImage.clearCache);

    test('retries transient SocketException resets and caches fetched bytes', () async {
      var attempts = 0;
      final expectedBytes = Uint8List.fromList([137, 80, 78, 71, 13, 10, 26, 10]);

      final fakeHeaders = _FakeHttpHeaders();
      final fakeResponse = _FakeHttpClientResponse(
        statusCode: HttpStatus.ok,
        bytes: expectedBytes,
      );
      final fakeRequest = _FakeHttpClientRequest(
        headers: fakeHeaders,
        onClose: () async {
          attempts++;
          if (attempts < 3) {
            throw const SocketException(
              'Connection reset by peer',
              osError: OSError('Connection reset by peer', 104),
            );
          }
          return fakeResponse;
        },
      );
      final fakeClient = _FakeHttpClient(request: fakeRequest);

      await HttpOverrides.runZoned(
        () async {
          const url =
              'https://65b56bbba6f4c9c7870520709fd7a165.r2.cloudflarestorage.com/ecomstorage/stores/tech-banner.jpg?X-Amz-Date=20261108T100000Z';
          final cacheKey = CloudflareR2Service.cacheKeyForUrl(url);

          final firstResult = await fetchResilientImageBytes(
            url,
            cacheKey: cacheKey,
          );
          expect(firstResult, equals(expectedBytes));
          expect(attempts, equals(3));

          // Second call should hit in-memory byte cache without network attempts.
          final secondResult = await fetchResilientImageBytes(
            url,
            cacheKey: cacheKey,
          );
          expect(secondResult, equals(expectedBytes));
          expect(attempts, equals(3));
        },
        createHttpClient: (_) => fakeClient,
      );
    });
  });

  group('ProductModel.fromJson', () {
    test('parses store metadata, gallery images, tags, and variants', () {
      final model = ProductModel.fromJson({
        'id': 'prod-000010',
        'name': 'MacBook Pro 14 M4 Pro',
        'slug': 'macbook-pro-14-m4-pro',
        'base_price': '1999.00',
        'compare_at_price': '2199.00',
        'category': {'id': 'cat-000006', 'name': 'Laptops'},
        'store': {
          'id': 'store-1',
          'name': 'PixelForge Tech',
          'logo_url': 'stores/tech-banner.jpg',
        },
        'images': [
          {'image_url': 'products/macbook-pro-14-m4.jpg'},
          {'image_url': 'products/macbook-pro-14-m4-side.jpg'},
        ],
        'tags': [
          {'name': 'New'},
          {'name': 'Best Seller'},
        ],
        'rating_average': '4.9',
        'rating_count': 42,
        'sold_count': 120,
        'status': 'active',
        'variants': [
          {
            'id': 'vrn-1',
            'name': '16GB / 512GB',
            'price': '1999.00',
            'stock_quantity': 8,
            'status': 'active',
          },
        ],
      });

      expect(model.id, equals('prod-000010'));
      expect(model.storeName, equals('PixelForge Tech'));
      expect(model.storeLogoUrl, equals('stores/tech-banner.jpg'));
      expect(model.imageUrl, equals('products/macbook-pro-14-m4.jpg'));
      expect(model.images.length, equals(2));
      expect(model.tags, equals(['New', 'Best Seller']));
      expect(model.ratingAverage, closeTo(4.9, 0.001));
      expect(model.ratingCount, equals(42));
      expect(model.soldCount, equals(120));
      expect(model.quantity, equals(8));
    });
  });

  group('Theme & Localization', () {
    test('en_US and km_KH translation maps contain identical key sets', () {
      final keys = AppTranslations().keys;
      final enKeys = keys['en_US']!.keys.toSet();
      final kmKeys = keys['km_KH']!.keys.toSet();

      expect(enKeys.difference(kmKeys), isEmpty);
      expect(kmKeys.difference(enKeys), isEmpty);
    });

    test('light and dark themes apply KantumruyPro font cleanly', () {
      expect(AppTheme.light.appBarTheme.titleTextStyle?.fontFamily, equals('KantumruyPro'));
      expect(AppTheme.dark.appBarTheme.titleTextStyle?.fontFamily, equals('KantumruyPro'));
      expect(AppTheme.light.chipTheme.labelStyle?.fontFamily, equals('KantumruyPro'));
      expect(AppTheme.dark.chipTheme.labelStyle?.fontFamily, equals('KantumruyPro'));
    });
  });

  testWidgets('AppNetworkImage renders fallback cleanly in light and dark themes', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: AppNetworkImage(
            imageUrl: null,
            width: 80,
            height: 80,
            fallbackIcon: Icons.shopping_bag_outlined,
          ),
        ),
      ),
    );
    expect(find.byIcon(Icons.shopping_bag_outlined), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const Scaffold(
          body: AppNetworkImage(
            imageUrl: '',
            width: 80,
            height: 80,
            fallbackIcon: Icons.inventory_2_outlined,
          ),
        ),
      ),
    );
    expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
  });

  group('MapLocationService Slippy Tiles', () {
    test('computes exact OpenStreetMap and Satellite tile URLs', () {
      final osmUrl = MapLocationService.getOsmTileUrl(11.5684, 104.8906, zoom: 15);
      expect(osmUrl, equals('https://tile.openstreetmap.org/15/25931/15323.png'));

      final satelliteUrl = MapLocationService.getSatelliteTileUrl(11.5684, 104.8906, zoom: 15);
      expect(
        satelliteUrl,
        equals('https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/15/15323/25931'),
      );
    });
  });

  testWidgets('AbaLogo renders branded ABA typography cleanly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AbaLogo(size: 48),
        ),
      ),
    );
    expect(find.text('ABA'), findsOneWidget);
  });
}

class _FakeHttpHeaders extends Fake implements HttpHeaders {
  final Map<String, String> values = {};

  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {
    values[name.toLowerCase()] = value.toString();
  }

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {
    values[name.toLowerCase()] = value.toString();
  }
}

class _FakeHttpClient extends Fake implements HttpClient {
  final HttpClientRequest request;

  _FakeHttpClient({required this.request});

  @override
  bool autoUncompress = false;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => request;
}

class _FakeHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  final HttpHeaders headers;

  @override
  bool persistentConnection = true;

  final Future<HttpClientResponse> Function() onClose;

  _FakeHttpClientRequest({required this.headers, required this.onClose});

  @override
  Future<HttpClientResponse> close() => onClose();
}

class _FakeHttpClientResponse extends Fake implements HttpClientResponse {
  @override
  final int statusCode;

  final Uint8List bytes;

  _FakeHttpClientResponse({required this.statusCode, required this.bytes});

  @override
  int get contentLength => bytes.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([bytes]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}
