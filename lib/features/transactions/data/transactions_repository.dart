import '../../../core/network/api_client.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/json_parsers.dart';
import '../domain/transaction_item.dart';

class TransactionsRepository {
  TransactionsRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<TransactionItem>> fetchTransactions() async {
    final envelope = await _apiClient.get('/transactions');
    final payload = JsonParsers.asMap(envelope.data);
    return JsonParsers.listOfMap(
      payload['data'],
    ).map(TransactionItem.fromJson).toList();
  }

  Future<TransactionItem> fetchTransaction(int id) async {
    final envelope = await _apiClient.get('/transactions/$id');
    return TransactionItem.fromJson(JsonParsers.asMap(envelope.data));
  }

  Future<void> createTransaction({
    required int accountId,
    required int categoryId,
    required String type,
    required int amount,
    required DateTime transactionDate,
    String? note,
    String? attachmentPath,
  }) async {
    await _apiClient.post(
      '/transactions',
      data: {
        'account_id': accountId,
        'category_id': categoryId,
        'type': type,
        'amount': amount,
        'transaction_date': AppFormatters.apiDate(transactionDate),
        'note': note,
        'attachment_path': attachmentPath,
      },
    );
  }

  Future<void> updateTransaction({
    required int id,
    required int accountId,
    required int categoryId,
    required String type,
    required int amount,
    required DateTime transactionDate,
    String? note,
    String? attachmentPath,
  }) async {
    await _apiClient.put(
      '/transactions/$id',
      data: {
        'account_id': accountId,
        'category_id': categoryId,
        'type': type,
        'amount': amount,
        'transaction_date': AppFormatters.apiDate(transactionDate),
        'note': note,
        'attachment_path': attachmentPath,
      },
    );
  }

  Future<void> deleteTransaction(int id) async {
    await _apiClient.delete('/transactions/$id');
  }
}
