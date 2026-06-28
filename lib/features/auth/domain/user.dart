import '../../../core/utils/json_parsers.dart';

class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String name;
  final String email;
  final DateTime? deletedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: JsonParsers.toInt(json['id']),
      name: json['name']?.toString() ?? '-',
      email: json['email']?.toString() ?? '-',
      deletedAt: JsonParsers.toDateTime(json['deleted_at']),
      createdAt: JsonParsers.toDateTime(json['created_at']),
      updatedAt: JsonParsers.toDateTime(json['updated_at']),
    );
  }
}
