import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../network/api_client.dart';

/// Service implementing the Cloudinary Direct Upload Flow
/// as specified in Section 6 and Section 8.14 of frontend_integration_guide.md.
class CloudinaryUploadService {
  final ApiClient _apiClient;
  final Dio _cloudinaryDio;

  CloudinaryUploadService({
    required ApiClient apiClient,
    Dio? cloudinaryDio,
  })  : _apiClient = apiClient,
        _cloudinaryDio = cloudinaryDio ?? Dio();

  /// Upload an image to Cloudinary using backend-signed parameters:
  /// 1. Request signed parameters from backend: POST /api/v1/uploads/cloudinary-signature/
  /// 2. Direct multipart upload to Cloudinary CDN
  /// 3. Confirm upload with backend: POST /api/v1/uploads/confirm/
  Future<String> uploadImage({
    required Uint8List bytes,
    required String fileName,
    String folder = 'avatars',
    String usageType = 'avatar',
    String mimeType = 'image/jpeg',
  }) async {
    // Step 1: Request signature from backend
    final signatureResponse = await _apiClient.post(
      ApiConstants.cloudinarySignature,
      data: {'folder': folder},
    );

    final responseData = signatureResponse.data;
    final Map<String, dynamic> sigData =
        responseData is Map<String, dynamic> && responseData['data'] is Map
            ? responseData['data'] as Map<String, dynamic>
            : (responseData is Map<String, dynamic> ? responseData : {});

    final apiKey = sigData['api_key']?.toString() ?? '';
    final timestamp = sigData['timestamp']?.toString() ?? '';
    final signature = sigData['signature']?.toString() ?? '';
    final cloudName = sigData['cloud_name']?.toString() ?? '';
    final targetFolder = sigData['folder']?.toString() ?? folder;

    if (cloudName.isEmpty || apiKey.isEmpty || signature.isEmpty) {
      throw Exception('Failed to obtain Cloudinary upload signature');
    }

    // Step 2: Direct multipart POST to Cloudinary CDN
    final uploadUrl = 'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: fileName),
      'api_key': apiKey,
      'timestamp': timestamp,
      'signature': signature,
      'folder': targetFolder,
    });

    final cloudinaryRes = await _cloudinaryDio.post(uploadUrl, data: formData);
    final cData = cloudinaryRes.data;

    final publicId = cData['public_id']?.toString() ?? '';
    final secureUrl = cData['secure_url']?.toString() ?? cData['url']?.toString() ?? '';
    final url = cData['url']?.toString() ?? secureUrl;

    if (secureUrl.isEmpty) {
      throw Exception('Cloudinary upload did not return a valid secure URL');
    }

    // Step 3: Confirm uploaded asset with backend
    try {
      await _apiClient.post(
        ApiConstants.confirmUpload,
        data: {
          'public_id': publicId,
          'url': url,
          'secure_url': secureUrl,
          'mime_type': mimeType,
          'usage_type': usageType,
        },
      );
    } catch (_) {
      // Backend confirmation is non-fatal for client displaying the image
    }

    return secureUrl;
  }
}
