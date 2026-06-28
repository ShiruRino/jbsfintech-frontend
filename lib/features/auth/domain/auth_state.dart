import 'user.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  const AuthState({required this.status, this.token, this.user});

  const AuthState.unknown() : this(status: AuthStatus.unknown);
  const AuthState.authenticated({required String token, User? user})
    : this(status: AuthStatus.authenticated, token: token, user: user);
  const AuthState.unauthenticated() : this(status: AuthStatus.unauthenticated);

  final AuthStatus status;
  final String? token;
  final User? user;
}
