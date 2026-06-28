import '../../../core/network/api_client.dart';
import '../../../core/utils/json_parsers.dart';
import '../../transactions/domain/transaction_item.dart';
import '../domain/account.dart';

class AccountsRepository {
  AccountsRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Account>> fetchAccounts() async {
    final envelope = await _apiClient.get('/accounts');
    return JsonParsers.listOfMap(envelope.data).map(Account.fromJson).toList();
  }

  Future<(Account, List<TransactionItem>)> fetchAccountDetail(int id) async {
    final envelope = await _apiClient.get('/accounts/$id');
    final data = JsonParsers.asMap(envelope.data);
    final account = Account.fromJson(JsonParsers.asMap(data['account']));
    final transactions = JsonParsers.listOfMap(
      data['latest_transactions'],
    ).map(TransactionItem.fromJson).toList();
    return (account, transactions);
  }

  Future<void> createAccount({
    required String name,
    required String type,
    required int initialBalance,
    required bool isActive,
  }) async {
    await _apiClient.post(
      '/accounts',
      data: {
        'name': name,
        'type': type,
        'initial_balance': initialBalance,
        'is_active': isActive,
      },
    );
  }

  Future<void> updateAccount({
    required int id,
    required String name,
    required String type,
    required int initialBalance,
    required bool isActive,
  }) async {
    await _apiClient.put(
      '/accounts/$id',
      data: {
        'name': name,
        'type': type,
        'initial_balance': initialBalance,
        'is_active': isActive,
      },
    );
  }

  Future<void> deleteAccount(int id) async {
    await _apiClient.delete('/accounts/$id');
  }
}
