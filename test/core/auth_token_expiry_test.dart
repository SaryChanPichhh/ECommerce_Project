import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mocktail/mocktail.dart';
import 'package:final_project/app/middlewares/auth_middleware.dart';
import 'package:final_project/app/routes/app_pages.dart';
import 'package:final_project/app/routes/app_routes.dart';
import 'package:final_project/core/network/user_session.dart';
import 'package:final_project/core/storage/local_storage.dart';
import 'package:final_project/core/utils/jwt_utils.dart';

class MockGetStorage extends Mock implements GetStorage {}

/// Helper function to generate a test JWT with custom claims.
String createTestJwt({required int expSeconds, Map<String, dynamic>? extraClaims}) {
  final header = base64Url.encode(utf8.encode(jsonEncode({'alg': 'HS256', 'typ': 'JWT'}))).replaceAll('=', '');
  final claims = {
    'sub': 'test@example.com',
    'user_id': 'test-user-id',
    'exp': expSeconds,
    if (extraClaims != null) ...extraClaims,
  };
  final payload = base64Url.encode(utf8.encode(jsonEncode(claims))).replaceAll('=', '');
  const signature = 'test_signature';
  return '$header.$payload.$signature';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('JwtUtils Token Expiry Tests', () {
    test('null or empty token is considered expired', () {
      expect(JwtUtils.isExpired(null), isTrue);
      expect(JwtUtils.isExpired(''), isTrue);
      expect(JwtUtils.isExpired('   '), isTrue);
    });

    test('malformed 3-part token is considered expired', () {
      expect(JwtUtils.isExpired('invalid.jwt.token'), isTrue);
    });

    test('token with past expiration date is expired', () {
      final pastEpoch = (DateTime.now().millisecondsSinceEpoch ~/ 1000) - 3600; // 1 hour ago
      final expiredToken = createTestJwt(expSeconds: pastEpoch);

      expect(JwtUtils.isExpired(expiredToken), isTrue);
      final expDate = JwtUtils.getExpirationDate(expiredToken);
      expect(expDate, isNotNull);
      expect(expDate!.isBefore(DateTime.now()), isTrue);
    });

    test('token with future expiration date is NOT expired', () {
      final futureEpoch = (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 3600; // 1 hour from now
      final validToken = createTestJwt(expSeconds: futureEpoch);

      expect(JwtUtils.isExpired(validToken), isFalse);
      final expDate = JwtUtils.getExpirationDate(validToken);
      expect(expDate, isNotNull);
      expect(expDate!.isAfter(DateTime.now()), isTrue);
    });

    test('decodes payload claims correctly', () {
      final epoch = 1757145600;
      final token = createTestJwt(
        expSeconds: epoch,
        extraClaims: {'role': 'customer', 'session_id': 'sess-123'},
      );

      final payload = JwtUtils.decodePayload(token);
      expect(payload, isNotNull);
      expect(payload!['sub'], 'test@example.com');
      expect(payload['role'], 'customer');
      expect(payload['session_id'], 'sess-123');
      expect(payload['exp'], epoch);
    });
  });

  group('LocalStorage & Auth Check Logic (No token / Expired token -> Must Login)', () {
    late MockGetStorage mockStorage;
    late LocalStorage localStorage;
    late Map<String, dynamic> memoryStore;

    setUp(() {
      Get.reset();
      memoryStore = <String, dynamic>{};
      mockStorage = MockGetStorage();

      when(() => mockStorage.read<String>(any())).thenAnswer((inv) {
        final key = inv.positionalArguments[0] as String;
        return memoryStore[key] as String?;
      });

      when(() => mockStorage.write(any(), any())).thenAnswer((inv) async {
        final key = inv.positionalArguments[0] as String;
        final val = inv.positionalArguments[1];
        memoryStore[key] = val;
      });

      when(() => mockStorage.remove(any())).thenAnswer((inv) async {
        final key = inv.positionalArguments[0] as String;
        memoryStore.remove(key);
      });

      when(() => mockStorage.erase()).thenAnswer((inv) async {
        memoryStore.clear();
      });

      localStorage = LocalStorage(storage: mockStorage);
      Get.put<LocalStorage>(localStorage, permanent: true);
    });

    test('Scenario 1: Local-storage has no token -> user must log in', () {
      expect(localStorage.getAccessToken(), isNull);
      expect(localStorage.isTokenExpired(), isTrue);
      expect(localStorage.isAuthenticated(), isFalse);
      expect(localStorage.mustLogin(), isTrue);
    });

    test('Scenario 2: Local-storage has expired token -> user must log in and tokens cleared', () async {
      final pastEpoch = (DateTime.now().millisecondsSinceEpoch ~/ 1000) - 3600;
      final expiredToken = createTestJwt(expSeconds: pastEpoch);

      await localStorage.saveAccessToken(expiredToken);
      expect(localStorage.getAccessToken(), equals(expiredToken));

      // Check expired logic
      expect(localStorage.isTokenExpired(), isTrue);
      expect(localStorage.isAuthenticated(), isFalse);
      expect(localStorage.mustLogin(), isTrue);

      // Verify that isAuthenticated() automatically wiped the expired token
      expect(localStorage.getAccessToken(), isNull);
    });

    test('Scenario 3: Local-storage has valid non-expired token -> user is authenticated', () async {
      final futureEpoch = (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 86400; // 1 day future
      final validToken = createTestJwt(expSeconds: futureEpoch);

      await localStorage.saveAccessToken(validToken);

      expect(localStorage.isTokenExpired(), isFalse);
      expect(localStorage.isAuthenticated(), isTrue);
      expect(localStorage.mustLogin(), isFalse);
      expect(localStorage.getAccessToken(), equals(validToken));
    });
  });

  group('AuthMiddleware Redirect Logic', () {
    late MockGetStorage mockStorage;
    late LocalStorage localStorage;
    late Map<String, dynamic> memoryStore;
    late AuthMiddleware middleware;

    setUp(() {
      Get.reset();
      memoryStore = <String, dynamic>{};
      mockStorage = MockGetStorage();

      when(() => mockStorage.read<String>(any())).thenAnswer((inv) {
        final key = inv.positionalArguments[0] as String;
        return memoryStore[key] as String?;
      });

      when(() => mockStorage.write(any(), any())).thenAnswer((inv) async {
        final key = inv.positionalArguments[0] as String;
        final val = inv.positionalArguments[1];
        memoryStore[key] = val;
      });

      when(() => mockStorage.remove(any())).thenAnswer((inv) async {
        final key = inv.positionalArguments[0] as String;
        memoryStore.remove(key);
      });

      localStorage = LocalStorage(storage: mockStorage);
      Get.put<LocalStorage>(localStorage, permanent: true);
      middleware = AuthMiddleware();
    });

    test('redirects to /login if token is missing', () {
      final redirect = middleware.redirect('/payment');
      expect(redirect, isNotNull);
      expect(redirect!.name, AppRoutes.login);
    });

    test('redirects to /login if token is expired', () async {
      final pastEpoch = (DateTime.now().millisecondsSinceEpoch ~/ 1000) - 7200;
      final expiredToken = createTestJwt(expSeconds: pastEpoch);
      await localStorage.saveAccessToken(expiredToken);

      final redirect = middleware.redirect('/payment');
      expect(redirect, isNotNull);
      expect(redirect!.name, AppRoutes.login);
    });

    test('proceeds to route (no redirect) if token is valid', () async {
      final futureEpoch = (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 7200;
      final validToken = createTestJwt(expSeconds: futureEpoch);
      await localStorage.saveAccessToken(validToken);

      final redirect = middleware.redirect('/payment');
      expect(redirect, isNull);
    });
  });

  group('UserSession Expiry State', () {
    setUp(() {
      UserSession.instance.clear();
    });

    test('UserSession is unauthenticated when token is null or empty', () {
      expect(UserSession.instance.isAuthenticated, isFalse);
      UserSession.instance.setToken('');
      expect(UserSession.instance.isAuthenticated, isFalse);
    });

    test('UserSession is unauthenticated when token is expired and clears session', () {
      final pastEpoch = (DateTime.now().millisecondsSinceEpoch ~/ 1000) - 100;
      final expiredToken = createTestJwt(expSeconds: pastEpoch);
      UserSession.instance.setToken(expiredToken);

      expect(UserSession.instance.isAuthenticated, isFalse);
      expect(UserSession.instance.accessToken, isNull);
    });

    test('UserSession is authenticated when token is valid and active', () {
      final futureEpoch = (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 10000;
      final validToken = createTestJwt(expSeconds: futureEpoch);
      UserSession.instance.setToken(validToken);

      expect(UserSession.instance.isAuthenticated, isTrue);
      expect(UserSession.instance.accessToken, equals(validToken));
    });
  });

  group('Initial Entry Point Configuration', () {
    test('Initial entry point route is AppRoutes.login', () {
      expect(AppPages.initial, equals(AppRoutes.login));
    });
  });
}
