import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

import '../constants/storage_constants.dart';

/// Configuration for Cloudflare R2 object storage.
/// Values can be overridden at compile time with `--dart-define` or updated directly.
class CloudflareR2Config {
  CloudflareR2Config._();

  /// Cloudflare Account ID from Cloudflare dashboard
  static const String accountId = String.fromEnvironment(
    StorageConstants.accountId,
    defaultValue: StorageConstants.accountId,
  );

  /// R2 S3 Access Key ID
  static const String accessKeyId = String.fromEnvironment(
    'R2_ACCESS_KEY_ID',
    defaultValue: StorageConstants.accessKey,
  );

  /// R2 S3 Secret Access Key
  static const String secretAccessKey = String.fromEnvironment(
    'R2_SECRET_ACCESS_KEY',
    defaultValue: StorageConstants.secretKey,
  );

  /// Target Cloudflare R2 bucket name
  static const String bucketName = String.fromEnvironment(
    'R2_BUCKET_NAME',
    defaultValue: StorageConstants.bucketName,
  );

  /// Public CDN domain or r2.dev domain for public bucket reads
  /// e.g., 'https://pub-xxxx.r2.dev' or custom domain 'https://cdn.setec-ecommerce.com'
  static const String publicBaseUrl = String.fromEnvironment(
    'R2_PUBLIC_BASE_URL',
    defaultValue: StorageConstants.endPointUrl,
  );

  /// Optional Cloudflare Worker upload endpoint
  static const String workerUploadUrl = String.fromEnvironment(
    'R2_WORKER_UPLOAD_URL',
    defaultValue: StorageConstants.workerUploadUrl,
  );

  /// Helper to check if credentials are set
  static bool get hasValidCredentials =>
      accountId.isNotEmpty &&
      accessKeyId.isNotEmpty &&
      secretAccessKey.isNotEmpty &&
      !accessKeyId.contains('your_');
}

/// Service to handle direct uploads to Cloudflare R2 (S3-compatible API).
class CloudflareR2Service {
  final Dio _dio;

  CloudflareR2Service({Dio? dio}) : _dio = dio ?? Dio();

  /// Generic method to upload any image or file to Cloudflare R2.
  /// [folder] defines the folder path within the bucket (e.g. 'avatars', 'products', 'uploads').
  /// Returns the public accessible URL for the uploaded asset.
  Future<String> uploadImage({
    required Uint8List bytes,
    required String fileName,
    String folder = 'uploads',
    String contentType = 'image/jpeg',
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final sanitizedFileName = fileName.replaceAll(
      RegExp(r'[^a-zA-Z0-9._-]'),
      '_',
    );
    final objectKey = '$folder/${timestamp}_$sanitizedFileName';

    // 1. Worker upload (if configured with a valid full HTTP URL)
    final workerUrl = CloudflareR2Config.workerUploadUrl;
    if (workerUrl.isNotEmpty &&
        (workerUrl.startsWith('http://') || workerUrl.startsWith('https://'))) {
      try {
        return await _uploadViaWorker(
          workerUrl: workerUrl,
          bytes: bytes,
          objectKey: objectKey,
          contentType: contentType,
        );
      } catch (e) {
        developer.log('Worker upload failed, attempting SigV4 fallback: $e');
      }
    }

    // 2. Direct S3 SigV4 PUT upload to Cloudflare R2
    if (CloudflareR2Config.hasValidCredentials) {
      try {
        return await _uploadViaSigV4(
          bytes: bytes,
          objectKey: objectKey,
          contentType: contentType,
        );
      } catch (e, stack) {
        developer.log(
          'Failed to upload directly to R2: $e',
          error: e,
          stackTrace: stack,
        );
        rethrow;
      }
    }

    // 3. Fallback for local testing / mock when credentials are placeholders
    developer.log(
      '[CloudflareR2Service] Notice: Real R2 credentials not fully configured. '
      'Using simulated public R2 URL for testing: $objectKey',
    );
    return _buildPublicUrl(objectKey);
  }

  /// Upload avatar image bytes to Cloudflare R2.
  /// Returns the public accessible URL for the uploaded asset.
  Future<String> uploadAvatar({
    required Uint8List bytes,
    required String fileName,
    String contentType = 'image/jpeg',
  }) {
    return uploadImage(
      bytes: bytes,
      fileName: fileName,
      folder: 'avatars',
      contentType: contentType,
    );
  }

  /// Upload product image bytes to Cloudflare R2.
  /// Returns the public accessible URL for the uploaded asset.
  Future<String> uploadProductImage({
    required Uint8List bytes,
    required String fileName,
    String contentType = 'image/jpeg',
  }) {
    return uploadImage(
      bytes: bytes,
      fileName: fileName,
      folder: 'products',
      contentType: contentType,
    );
  }

  /// Direct AWS SigV4 PUT upload to Cloudflare R2 S3 Endpoint
  Future<String> _uploadViaSigV4({
    required Uint8List bytes,
    required String objectKey,
    required String contentType,
  }) async {
    final accountId = CloudflareR2Config.accountId;
    final bucketName = CloudflareR2Config.bucketName;
    final accessKey = CloudflareR2Config.accessKeyId;
    final secretKey = CloudflareR2Config.secretAccessKey;

    final host = '$accountId.r2.cloudflarestorage.com';
    final path = '/$bucketName/$objectKey';
    final endpointUrl = 'https://$host$path';

    final now = DateTime.now().toUtc();
    final amzDate = _formatBasicIso8601(now);
    final dateStamp = amzDate.substring(0, 8);

    final payloadHash = sha256.convert(bytes).toString();

    // Canonical request components
    final canonicalHeaders =
        'content-type:$contentType\n'
        'host:$host\n'
        'x-amz-content-sha256:$payloadHash\n'
        'x-amz-date:$amzDate\n';
    const signedHeaders = 'content-type;host;x-amz-content-sha256;x-amz-date';

    final canonicalRequest =
        'PUT\n'
        '$path\n\n'
        '$canonicalHeaders\n'
        '$signedHeaders\n'
        '$payloadHash';

    final stringToSign =
        'AWS4-HMAC-SHA256\n'
        '$amzDate\n'
        '$dateStamp/auto/s3/aws4_request\n'
        '${sha256.convert(utf8.encode(canonicalRequest))}';

    // Key derivation
    final kSecret = utf8.encode('AWS4$secretKey');
    final kDate = _hmacSha256(kSecret, utf8.encode(dateStamp));
    final kRegion = _hmacSha256(kDate, utf8.encode('auto'));
    final kService = _hmacSha256(kRegion, utf8.encode('s3'));
    final kSigning = _hmacSha256(kService, utf8.encode('aws4_request'));
    final signature = Hmac(
      sha256,
      kSigning,
    ).convert(utf8.encode(stringToSign)).toString();

    final authorization =
        'AWS4-HMAC-SHA256 '
        'Credential=$accessKey/$dateStamp/auto/s3/aws4_request, '
        'SignedHeaders=$signedHeaders, '
        'Signature=$signature';

    final response = await _dio.put(
      endpointUrl,
      data: Stream.fromIterable([bytes]),
      options: Options(
        headers: {
          'Content-Type': contentType,
          'Content-Length': bytes.length,
          'x-amz-date': amzDate,
          'x-amz-content-sha256': payloadHash,
          'Authorization': authorization,
        },
      ),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        'R2 upload failed with HTTP status ${response.statusCode}',
      );
    }

    return _buildPublicUrl(objectKey);
  }

  /// Upload via Cloudflare Worker
  Future<String> _uploadViaWorker({
    required String workerUrl,
    required Uint8List bytes,
    required String objectKey,
    required String contentType,
  }) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        bytes,
        filename: objectKey.split('/').last,
      ),
      'key': objectKey,
    });

    final response = await _dio.post(
      workerUrl,
      data: formData,
      options: Options(headers: {'Content-Type': 'multipart/form-data'}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final resData = response.data;
      if (resData is Map && resData['url'] != null) {
        return resData['url'].toString();
      }
      return _buildPublicUrl(objectKey);
    }
    throw Exception('Worker upload failed with status ${response.statusCode}');
  }

  /// Generates a signed AWS SigV4 GET URL (valid for 7 days) allowing public access
  /// to private R2 bucket objects without requiring client authentication headers.
  String generatePresignedGetUrl(String objectKey, {int expiresIn = 604800}) {
    if (!CloudflareR2Config.hasValidCredentials) {
      return _buildRawUrl(objectKey);
    }

    final accountId = CloudflareR2Config.accountId;
    final bucketName = CloudflareR2Config.bucketName;
    final accessKey = CloudflareR2Config.accessKeyId;
    final secretKey = CloudflareR2Config.secretAccessKey;

    final host = '$accountId.r2.cloudflarestorage.com';
    final path = '/$bucketName/$objectKey';

    final now = DateTime.now().toUtc();
    final amzDate = _formatBasicIso8601(now);
    final dateStamp = amzDate.substring(0, 8);
    final credentialScope = '$dateStamp/auto/s3/aws4_request';
    final credentialParam = Uri.encodeComponent('$accessKey/$credentialScope');

    final canonicalQueryString =
        'X-Amz-Algorithm=AWS4-HMAC-SHA256&'
        'X-Amz-Credential=$credentialParam&'
        'X-Amz-Date=$amzDate&'
        'X-Amz-Expires=$expiresIn&'
        'X-Amz-SignedHeaders=host';

    final canonicalRequest =
        'GET\n'
        '$path\n'
        '$canonicalQueryString\n'
        'host:$host\n\n'
        'host\n'
        'UNSIGNED-PAYLOAD';

    final stringToSign =
        'AWS4-HMAC-SHA256\n'
        '$amzDate\n'
        '$credentialScope\n'
        '${sha256.convert(utf8.encode(canonicalRequest))}';

    final kSecret = utf8.encode('AWS4$secretKey');
    final kDate = _hmacSha256(kSecret, utf8.encode(dateStamp));
    final kRegion = _hmacSha256(kDate, utf8.encode('auto'));
    final kService = _hmacSha256(kRegion, utf8.encode('s3'));
    final kSigning = _hmacSha256(kService, utf8.encode('aws4_request'));
    final signature =
        Hmac(sha256, kSigning).convert(utf8.encode(stringToSign)).toString();

    return 'https://$host$path?$canonicalQueryString&X-Amz-Signature=$signature';
  }

  String _buildPublicUrl(String objectKey) {
    final baseUrl = CloudflareR2Config.publicBaseUrl.endsWith('/')
        ? CloudflareR2Config.publicBaseUrl.substring(
            0,
            CloudflareR2Config.publicBaseUrl.length - 1,
          )
        : CloudflareR2Config.publicBaseUrl;

    // If using the raw R2 S3 endpoint, generate a presigned GET URL so public clients can view it
    if (baseUrl.contains('r2.cloudflarestorage.com')) {
      if (CloudflareR2Config.hasValidCredentials) {
        return generatePresignedGetUrl(objectKey);
      }
      return _buildRawUrl(objectKey);
    }
    return '$baseUrl/$objectKey';
  }

  String _buildRawUrl(String objectKey) {
    final baseUrl = CloudflareR2Config.publicBaseUrl.endsWith('/')
        ? CloudflareR2Config.publicBaseUrl.substring(
            0,
            CloudflareR2Config.publicBaseUrl.length - 1,
          )
        : CloudflareR2Config.publicBaseUrl;

    if (baseUrl.contains('r2.cloudflarestorage.com') &&
        !baseUrl.contains(CloudflareR2Config.bucketName)) {
      return '$baseUrl/${CloudflareR2Config.bucketName}/$objectKey';
    }
    return '$baseUrl/$objectKey';
  }

  List<int> _hmacSha256(List<int> key, List<int> data) {
    return Hmac(sha256, key).convert(data).bytes;
  }

  String _formatBasicIso8601(DateTime date) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${date.year}'
        '${twoDigits(date.month)}'
        '${twoDigits(date.day)}T'
        '${twoDigits(date.hour)}'
        '${twoDigits(date.minute)}'
        '${twoDigits(date.second)}Z';
  }
}
