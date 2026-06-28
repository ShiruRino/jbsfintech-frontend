class JsonParsers {
  const JsonParsers._();

  static int toInt(dynamic value, {int fallback = 0}) {
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.round();
    }
    if (value is String) {
      return int.tryParse(value) ?? double.tryParse(value)?.round() ?? fallback;
    }
    return fallback;
  }

  static double toDouble(dynamic value, {double fallback = 0}) {
    if (value is int) {
      return value.toDouble();
    }
    if (value is double) {
      return value;
    }
    if (value is String) {
      return double.tryParse(value) ?? fallback;
    }
    return fallback;
  }

  static bool toBool(dynamic value, {bool fallback = false}) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    if (value is String) {
      final normalized = value.toLowerCase();
      if (normalized == 'true' || normalized == '1') {
        return true;
      }
      if (normalized == 'false' || normalized == '0') {
        return false;
      }
    }
    return fallback;
  }

  static DateTime? toDateTime(dynamic value) {
    if (value is DateTime) {
      return value;
    }
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  static Map<String, dynamic> asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return <String, dynamic>{};
  }

  static List<Map<String, dynamic>> listOfMap(dynamic value) {
    if (value is! List) {
      return const <Map<String, dynamic>>[];
    }

    return value.map(asMap).toList();
  }

  static Map<String, List<String>> mapOfStringList(dynamic value) {
    final map = asMap(value);
    return map.map(
      (key, val) => MapEntry(
        key,
        (val is List ? val : [val]).map((item) => item.toString()).toList(),
      ),
    );
  }
}
