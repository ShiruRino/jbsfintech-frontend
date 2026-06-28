import '../../../core/utils/json_parsers.dart';

class Category {
  const Category({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.isActive,
  });

  final int id;
  final String name;
  final String type;
  final String? icon;
  final bool isActive;

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: JsonParsers.toInt(json['id']),
      name: json['name']?.toString() ?? '-',
      type: json['type']?.toString() ?? 'expense',
      icon: json['icon']?.toString(),
      isActive: JsonParsers.toBool(json['is_active'], fallback: true),
    );
  }
}

const Map<String, String> categoryIconLabels = {
  'wallet': 'Dompet',
  'food': 'Makan',
  'transport': 'Transport',
  'salary': 'Gaji',
  'shopping': 'Belanja',
  'bills': 'Tagihan',
};
