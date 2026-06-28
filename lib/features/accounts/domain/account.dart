import '../../../core/utils/json_parsers.dart';

class Account {
  const Account({
    required this.id,
    required this.name,
    required this.type,
    required this.initialBalance,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.isActive,
  });

  final int id;
  final String name;
  final String type;
  final int initialBalance;
  final int totalIncome;
  final int totalExpense;
  final int balance;
  final bool isActive;

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: JsonParsers.toInt(json['id']),
      name: json['name']?.toString() ?? '-',
      type: json['type']?.toString() ?? 'cash',
      initialBalance: JsonParsers.toInt(json['initial_balance']),
      totalIncome: JsonParsers.toInt(json['total_income']),
      totalExpense: JsonParsers.toInt(json['total_expense']),
      balance: JsonParsers.toInt(json['balance']),
      isActive: JsonParsers.toBool(json['is_active'], fallback: true),
    );
  }
}

class AccountDetail {
  const AccountDetail({
    required this.account,
    required this.latestTransactions,
  });

  final Account account;
  final List<int> latestTransactions;
}
