import 'dart:convert';

/// Utility class for parsing and validating JSON Web Tokens (JWT).
class JwtUtils {
  JwtUtils._();

  /// Decodes the payload portion of a JWT string into a key-value Map.
  /// Returns `null` if the token cannot be parsed or is not a valid JWT format.
  static Map<String, dynamic>? decodePayload(String token) {
    try {
      final parts = token.trim().split('.');
      if (parts.length != 3) {
        return null;
      }

      final normalized = base64Url.normalize(parts[1]);
      final payloadString = utf8.decode(base64Url.decode(normalized));
      final decoded = jsonDecode(payloadString);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Extracts the expiration date from the JWT's 'exp' claim.
  /// Returns `null` if the token is invalid, unparseable, or lacks an 'exp' claim.
  static DateTime? getExpirationDate(String? token) {
    if (token == null || token.trim().isEmpty) {
      return null;
    }

    final payload = decodePayload(token);
    if (payload == null) {
      return null;
    }

    final exp = payload['exp'];
    if (exp == null) {
      return null;
    }

    int? expSeconds;
    if (exp is int) {
      expSeconds = exp;
    } else if (exp is num) {
      expSeconds = exp.toInt();
    } else if (exp is String) {
      expSeconds = int.tryParse(exp);
    }

    if (expSeconds == null) {
      return null;
    }

    return DateTime.fromMillisecondsSinceEpoch(expSeconds * 1000, isUtc: true);
  }

  /// Checks if a token is expired.
  ///
  /// Returns `true` if:
  /// - The token is `null` or empty.
  /// - The token is a 3-part JWT and cannot be decoded (corrupted).
  /// - The token is a JWT whose 'exp' claim timestamp is in the past.
  ///
  /// Returns `false` if:
  /// - The token is a valid JWT whose 'exp' timestamp is in the future.
  /// - The token is an opaque token without an expiration claim.
  static bool isExpired(String? token, {Duration buffer = Duration.zero}) {
    if (token == null || token.trim().isEmpty) {
      return true;
    }

    final trimmed = token.trim();
    final parts = trimmed.split('.');

    // If it is in JWT format (3 parts), attempt to check expiration
    if (parts.length == 3) {
      final expDate = getExpirationDate(trimmed);
      if (expDate == null) {
        // If it's a 3-part token that failed payload decoding, consider it corrupted/expired
        final payload = decodePayload(trimmed);
        if (payload == null) {
          return true;
        }
        // If payload is valid but has no 'exp' claim, it has no expiry
        return false;
      }

      final nowUtc = DateTime.now().toUtc();
      return nowUtc.isAfter(expDate.subtract(buffer));
    }

    // For non-JWT opaque tokens, if not empty, it is not expired by JWT rules
    return false;
  }
}
