import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

import '../../../core/network/api_client.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/json_parsers.dart';
import '../domain/transaction_attachment.dart';
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
    TransactionAttachmentFile? attachment,
  }) async {
    await _apiClient.post(
      '/transactions',
      data: await buildTransactionFormData(
        accountId: accountId,
        categoryId: categoryId,
        type: type,
        amount: amount,
        transactionDate: transactionDate,
        note: note,
        attachment: attachment,
      ),
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
    TransactionAttachmentFile? attachment,
    bool removeAttachment = false,
  }) async {
    await _apiClient.post(
      '/transactions/$id',
      data: await buildTransactionFormData(
        accountId: accountId,
        categoryId: categoryId,
        type: type,
        amount: amount,
        transactionDate: transactionDate,
        note: note,
        attachment: attachment,
        methodOverride: 'PUT',
        removeAttachment: removeAttachment,
      ),
    );
  }

  Future<void> deleteTransaction(int id) async {
    await _apiClient.delete('/transactions/$id');
  }
}

Future<FormData> buildTransactionFormData({
  required int accountId,
  required int categoryId,
  required String type,
  required int amount,
  required DateTime transactionDate,
  String? note,
  TransactionAttachmentFile? attachment,
  String? methodOverride,
  bool removeAttachment = false,
}) async {
  final data = <String, dynamic>{
    'account_id': accountId,
    'category_id': categoryId,
    'type': type,
    'amount': amount,
    'transaction_date': AppFormatters.apiDate(transactionDate),
  };

  if (note != null && note.trim().isNotEmpty) {
    data['note'] = note.trim();
  }

  if (methodOverride != null) {
    data['_method'] = methodOverride;
  }

  if (removeAttachment) {
    data['remove_attachment'] = '1';
  }

  if (attachment != null) {
    final mimeParts = attachment.mimeType.split('/');
    data['attachment'] = await MultipartFile.fromFile(
      attachment.path,
      filename: attachment.filename,
      contentType: MediaType(mimeParts.first, mimeParts.last),
    );
  }

  return FormData.fromMap(data);
}
