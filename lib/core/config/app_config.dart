class AppConfig {
  const AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://airaai.my.id/jbsfintech/api',
  );

  static const String authHeaderName = String.fromEnvironment(
    'AUTH_HEADER_NAME',
    defaultValue: 'Authorization',
  );

  static const String authHeaderPrefix = String.fromEnvironment(
    'AUTH_HEADER_PREFIX',
    defaultValue: 'Bearer',
  );

  static String formatAuthHeader(String token) {
    if (authHeaderPrefix.isEmpty) {
      return token;
    }

    return '$authHeaderPrefix $token';
  }
}
