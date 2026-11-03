import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/login_request_model.dart';
import '../models/register_request_model.dart';
import '../models/user_model.dart';

/// Remote data source for authentication.
/// Communicates with the REST API through ApiClient.
abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(LoginRequestModel request);
  Future<Map<String, dynamic>> register(RegisterRequestModel request);
  Future<void> logout();
  Future<UserModel> getCurrentUser();
  Future<UserModel> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? avatarUrl,
    String? dateOfBirth,
    String? gender,
    String? preferredLanguage,
    bool? marketingOptIn,
  });
  Future<String> forgotPassword(String email);
  Future<String> resetPassword(String resetToken, String newPassword);
  Future<Map<String, dynamic>> refreshToken();
}

/// Implementation of [AuthRemoteDataSource].
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<Map<String, dynamic>> login(LoginRequestModel request) async {
    final response = await _apiClient.post(
      ApiConstants.login,
      data: request.toJson(),
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data;
    }
    throw const ServerException(message: 'Invalid server response');
  }

  @override
  Future<Map<String, dynamic>> register(RegisterRequestModel request) async {
    final response = await _apiClient.post(
      ApiConstants.register,
      data: request.toJson(),
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data;
    }
    throw const ServerException(message: 'Invalid server response');
  }

  @override
  Future<void> logout() async {
    try {
      await _apiClient.post(ApiConstants.logout);
    } on UnauthorizedException {
      // Token already invalid or expired, continue
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    // Attempt /users/me/ for detailed profile
    try {
      final response = await _apiClient.get(ApiConstants.userMe);
      final data = response.data;
      final userMap = data is Map<String, dynamic> && data.containsKey('data')
          ? data['data'] as Map<String, dynamic>
          : data as Map<String, dynamic>;
      return UserModel.fromJson(userMap);
    } catch (_) {
      // Fallback to /auth/me/
      final response = await _apiClient.get(ApiConstants.authMe);
      final data = response.data;
      final userMap = data is Map<String, dynamic> && data.containsKey('data')
          ? data['data'] as Map<String, dynamic>
          : data as Map<String, dynamic>;
      return UserModel.fromJson(userMap);
    }
  }

  @override
  Future<UserModel> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? avatarUrl,
    String? dateOfBirth,
    String? gender,
    String? preferredLanguage,
    bool? marketingOptIn,
  }) async {
    final Map<String, dynamic> body = {};
    if (firstName != null) body['first_name'] = firstName;
    if (lastName != null) body['last_name'] = lastName;
    if (phone != null) body['phone_number'] = phone;
    if (avatarUrl != null) body['avatar_url'] = avatarUrl;

    final response = await _apiClient.patch(
      ApiConstants.userMe,
      data: body,
    );

    // Optional update for demographic preferences if specified
    if (dateOfBirth != null || gender != null || preferredLanguage != null || marketingOptIn != null) {
      try {
        final profileBody = <String, dynamic>{};
        if (dateOfBirth != null) profileBody['date_of_birth'] = dateOfBirth;
        if (gender != null) profileBody['gender'] = gender;
        if (preferredLanguage != null) profileBody['preferred_language'] = preferredLanguage;
        if (marketingOptIn != null) profileBody['marketing_opt_in'] = marketingOptIn;
        await _apiClient.patch(
          '/users/me/profile/',
          data: profileBody,
        );
      } catch (_) {
        // Demographics failure is non-fatal to personal info update
      }
    }

    final data = response.data;
    final userMap = data is Map<String, dynamic> && data.containsKey('data')
        ? data['data'] as Map<String, dynamic>
        : data as Map<String, dynamic>;
    return UserModel.fromJson(userMap);
  }

  @override
  Future<String> forgotPassword(String email) async {
    final response = await _apiClient.post(
      ApiConstants.forgotPassword,
      data: {'email': email},
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final innerData = data['data'];
      if (innerData is Map<String, dynamic> && innerData['message'] != null) {
        return innerData['message'].toString();
      }
      if (data['message'] != null) {
        return data['message'].toString();
      }
    }
    return 'Password reset instructions sent to your email.';
  }

  @override
  Future<String> resetPassword(String resetToken, String newPassword) async {
    final response = await _apiClient.post(
      ApiConstants.resetPassword,
      data: {
        'reset_token': resetToken,
        'new_password': newPassword,
      },
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final innerData = data['data'];
      if (innerData is Map<String, dynamic> && innerData['message'] != null) {
        return innerData['message'].toString();
      }
      if (data['message'] != null) {
        return data['message'].toString();
      }
    }
    return 'Password has been successfully reset.';
  }

  @override
  Future<Map<String, dynamic>> refreshToken() async {
    final response = await _apiClient.post(ApiConstants.refreshToken);
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data;
    }
    throw const ServerException(message: 'Invalid server response for token refresh');
  }
}
