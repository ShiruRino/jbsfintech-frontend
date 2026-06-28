import '../../../core/utils/json_parsers.dart';
import 'user.dart';

class LoginResponse {
  const LoginResponse({required this.token, this.user});

  final String token;
  final User? user;

  factory LoginResponse.fromData(dynamic data) {
    if (data is String) {
      return LoginResponse(token: data);
    }

    final map = JsonParsers.asMap(data);
    return LoginResponse(
      token: map['token']?.toString() ?? '',
      user: map['user'] == null
          ? null
          : User.fromJson(JsonParsers.asMap(map['user'])),
    );
  }
}
