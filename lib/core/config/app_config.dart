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

  static String? resolveStorageUrl(String? path) {
    final value = path?.trim();
    if (value == null || value.isEmpty) {
      return null;
    }

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    final apiUri = Uri.parse(apiBaseUrl);
    final storageBasePath = apiUri.path.replaceFirst(RegExp(r'/api/?$'), '');
    final cleanPath = value.replaceFirst(RegExp(r'^/+'), '');
    final relativeStoragePath = cleanPath.startsWith('storage/')
        ? cleanPath.substring('storage/'.length)
        : cleanPath;

    return apiUri
        .replace(path: '$storageBasePath/storage/$relativeStoragePath')
        .toString();
  }
}
