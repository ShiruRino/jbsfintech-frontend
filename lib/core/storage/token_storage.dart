import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class TokenStorageBackend {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class FlutterSecureStorageBackend implements TokenStorageBackend {
  FlutterSecureStorageBackend(this._storage);

  final FlutterSecureStorage _storage;

  @override
  Future<void> delete(String key) => _storage.delete(key: key);

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);
}

class SecureTokenStorage {
  SecureTokenStorage(this._backend);

  static const tokenKey = 'auth_token';
  final TokenStorageBackend _backend;

  Future<String?> readToken() => _backend.read(tokenKey);
  Future<void> writeToken(String token) => _backend.write(tokenKey, token);
  Future<void> clearToken() => _backend.delete(tokenKey);
}
