import 'dart:convert';

Map<String, dynamic> decodeMap(value) {
  if (value is Map<String, dynamic>) {
    return value;
  }

  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }

  if (value is String) {
    final decoded = jsonDecode(value);

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }
  }

  throw const FormatException('Invalid map value');
}

List<dynamic> decodeList(value) {
  if (value is List) {
    return value;
  }

  if (value is String) {
    final decoded = jsonDecode(value);

    if (decoded is List) {
      return decoded;
    }
  }

  throw const FormatException('Invalid list value');
}
