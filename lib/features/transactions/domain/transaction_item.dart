import '../../../core/utils/json_parsers.dart';
import '../../accounts/domain/account.dart';
import '../../categories/domain/category.dart';

class TransactionItem {
  const TransactionItem({
    required this.id,
    this.account,
    this.category,
    required this.type,
    required this.amount,
    required this.transactionDate,
    this.note,
    this.attachmentPath,
  });

  final int id;
  final Account? account;
  final Category? category;
  final String type;
  final int amount;
  final DateTime? transactionDate;
  final String? note;
  final String? attachmentPath;

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    final accountJson = JsonParsers.asMap(json['account']);
    final categoryJson = JsonParsers.asMap(json['category']);

    return TransactionItem(
      id: JsonParsers.toInt(json['id']),
      account: accountJson.isEmpty ? null : Account.fromJson(accountJson),
      category: categoryJson.isEmpty ? null : Category.fromJson(categoryJson),
      type: json['type']?.toString() ?? 'expense',
      amount: JsonParsers.toInt(json['amount']),
      transactionDate: JsonParsers.toDateTime(json['transaction_date']),
      note: json['note']?.toString(),
      attachmentPath: json['attachment_path']?.toString(),
    );
  }
}
