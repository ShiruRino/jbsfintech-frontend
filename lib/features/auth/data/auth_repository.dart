import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../../../core/utils/json_parsers.dart';
import '../domain/login_response.dart';
import '../domain/user.dart';

class AuthRepository {
  AuthRepository(this._apiClient, this._tokenStorage);

  final ApiClient _apiClient;
  final SecureTokenStorage _tokenStorage;

  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    final envelope = await _apiClient.post(
      '/login',
      authRequired: false,
      data: {'email': email, 'password': password},
    );
    return LoginResponse.fromData(envelope.data);
  }

  Future<User> getUser() async {
    final envelope = await _apiClient.get('/user');
    return User.fromJson(JsonParsers.asMap(envelope.data));
  }

  Future<void> logout() async {
    try {
      await _apiClient.post('/logout');
    } finally {
      await _tokenStorage.clearToken();
    }
  }

  Future<void> persistToken(String token) => _tokenStorage.writeToken(token);
  Future<String?> readToken() => _tokenStorage.readToken();
  Future<void> clearToken() => _tokenStorage.clearToken();
}
