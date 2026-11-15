import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/login_request_model.dart';
import '../models/user_model.dart';

/// Remote data source for authentication.
/// Communicates with the REST API through ApiClient.
abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(LoginRequestModel request);
  Future<void> logout();
  Future<UserModel> getCurrentUser();
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
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<void> logout() async {
    await _apiClient.post(ApiConstants.logout);
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final response = await _apiClient.get(ApiConstants.authMe);
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }
}
