import 'package:flutter/material.dart';

class CategoryIconOption {
  const CategoryIconOption({
    required this.key,
    required this.label,
    required this.icon,
  });

  final String key;
  final String label;
  final IconData icon;
}

const categoryIconOptions = <CategoryIconOption>[
  CategoryIconOption(
    key: 'account_balance_wallet_rounded',
    label: 'Dompet',
    icon: Icons.account_balance_wallet_rounded,
  ),
  CategoryIconOption(
    key: 'restaurant_rounded',
    label: 'Makan',
    icon: Icons.restaurant_rounded,
  ),
  CategoryIconOption(
    key: 'directions_car_rounded',
    label: 'Transport',
    icon: Icons.directions_car_rounded,
  ),
  CategoryIconOption(
    key: 'payments_rounded',
    label: 'Gaji',
    icon: Icons.payments_rounded,
  ),
  CategoryIconOption(
    key: 'shopping_bag_rounded',
    label: 'Belanja',
    icon: Icons.shopping_bag_rounded,
  ),
  CategoryIconOption(
    key: 'receipt_long_rounded',
    label: 'Tagihan',
    icon: Icons.receipt_long_rounded,
  ),
  CategoryIconOption(
    key: 'home_work_rounded',
    label: 'Rumah',
    icon: Icons.home_work_rounded,
  ),
  CategoryIconOption(
    key: 'school_rounded',
    label: 'Edukasi',
    icon: Icons.school_rounded,
  ),
  CategoryIconOption(
    key: 'favorite_rounded',
    label: 'Kesehatan',
    icon: Icons.favorite_rounded,
  ),
  CategoryIconOption(
    key: 'savings_rounded',
    label: 'Investasi',
    icon: Icons.savings_rounded,
  ),
];

const _legacyIconAliases = <String, String>{
  'wallet': 'account_balance_wallet_rounded',
  'food': 'restaurant_rounded',
  'transport': 'directions_car_rounded',
  'salary': 'payments_rounded',
  'shopping': 'shopping_bag_rounded',
  'bills': 'receipt_long_rounded',
};

String normalizeCategoryIconKey(String? key) {
  if (key == null || key.isEmpty) {
    return categoryIconOptions.first.key;
  }
  return _legacyIconAliases[key] ?? key;
}

CategoryIconOption categoryIconOptionFor(String? key) {
  final normalized = normalizeCategoryIconKey(key);
  return categoryIconOptions.firstWhere(
    (option) => option.key == normalized,
    orElse: () => categoryIconOptions.first,
  );
}
