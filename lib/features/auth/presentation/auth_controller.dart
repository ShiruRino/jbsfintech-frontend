import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/providers.dart';
import '../data/auth_repository.dart';
import '../domain/auth_state.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(apiClientProvider),
    ref.watch(tokenStorageProvider),
  );
});

class AuthController extends Notifier<AuthState> implements Listenable {
  VoidCallback? _routerListener;

  @override
  AuthState build() => const AuthState.unknown();

  Future<void> initialize() async {
    final repository = ref.read(authRepositoryProvider);
    final token = await repository.readToken();
    if (token == null || token.isEmpty) {
      state = const AuthState.unauthenticated();
      _routerListener?.call();
      return;
    }

    try {
      final user = await repository.getUser();
      state = AuthState.authenticated(token: token, user: user);
    } catch (_) {
      await repository.clearToken();
      state = const AuthState.unauthenticated();
    }
    _routerListener?.call();
  }

  Future<bool> login(String email, String password) async {
    final repository = ref.read(authRepositoryProvider);
    try {
      final response = await repository.login(email: email, password: password);
      await repository.persistToken(response.token);
      final user = response.user ?? await repository.getUser();
      state = AuthState.authenticated(token: response.token, user: user);
      _routerListener?.call();
      return true;
    } catch (_) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AuthState.unauthenticated();
    _routerListener?.call();
  }

  Future<void> handleUnauthorized() async {
    await ref.read(authRepositoryProvider).clearToken();
    state = const AuthState.unauthenticated();
    _routerListener?.call();
  }

  @override
  void addListener(VoidCallback listener) {
    _routerListener = listener;
  }

  @override
  void removeListener(VoidCallback listener) {
    if (_routerListener == listener) {
      _routerListener = null;
    }
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
