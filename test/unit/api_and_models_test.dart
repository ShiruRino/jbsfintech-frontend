import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:jbsfintech/core/network/api_response.dart';
import 'package:jbsfintech/core/storage/token_storage.dart';
import 'package:jbsfintech/core/utils/formatters.dart';
import 'package:jbsfintech/features/accounts/domain/account.dart';
import 'package:jbsfintech/features/auth/domain/login_response.dart';
import 'package:jbsfintech/features/categories/domain/category.dart';
import 'package:jbsfintech/features/transactions/domain/transaction_item.dart';

class InMemoryTokenBackend implements TokenStorageBackend {
  String? value;

  @override
  Future<void> delete(String key) async {
    value = null;
  }

  @override
  Future<String?> read(String key) async => value;

  @override
  Future<void> write(String key, String value) async {
    this.value = value;
  }
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID');
  });

  group('Api envelope parsing', () {
    test('parses success payload', () {
      final envelope = ApiEnvelope<Map<String, dynamic>>.fromJson({
        'status': 'success',
        'message': 'ok',
        'data': {'name': 'jb'},
        'errors': null,
      }, (data) => Map<String, dynamic>.from(data as Map));

      expect(envelope.status, 'success');
      expect(envelope.message, 'ok');
      expect(envelope.data['name'], 'jb');
      expect(envelope.errors, isEmpty);
    });
  });

  group('Login response parsing', () {
    test('supports actual response object with token and user', () {
      final response = LoginResponse.fromData({
        'token': 'abc123',
        'user': {'id': 1, 'name': 'JBS', 'email': 'admin@gmail.com'},
      });

      expect(response.token, 'abc123');
      expect(response.user?.name, 'JBS');
    });

    test('supports documented token string fallback', () {
      final response = LoginResponse.fromData('token-only');
      expect(response.token, 'token-only');
      expect(response.user, isNull);
    });
  });

  group('Utilities and storage', () {
    test('formats amount and dates for Indonesian locale', () {
      expect(AppFormatters.currency(1250000), 'Rp1.250.000');
      expect(AppFormatters.displayDate(DateTime(2026, 6, 28)), '28 Jun 2026');
      expect(AppFormatters.apiDate(DateTime(2026, 6, 28)), '2026-06-28');
    });

    test('persists auth token through storage wrapper', () async {
      final backend = InMemoryTokenBackend();
      final storage = SecureTokenStorage(backend);

      await storage.writeToken('secure-token');
      expect(await storage.readToken(), 'secure-token');

      await storage.clearToken();
      expect(await storage.readToken(), isNull);
    });
  });

  group('Model parsing', () {
    test('parses inconsistent account types safely', () {
      final account = Account.fromJson({
        'id': '2',
        'name': 'Dana',
        'type': 'ewallet',
        'initial_balance': '227',
        'total_income': 5000000.0,
        'total_expense': '20000',
        'balance': '4980227',
        'is_active': 1,
      });

      expect(account.id, 2);
      expect(account.balance, 4980227);
      expect(account.isActive, isTrue);
    });

    test('parses category and transaction payloads defensively', () {
      final category = Category.fromJson({
        'id': 1,
        'name': 'Transport',
        'type': 'expense',
        'icon': null,
        'is_active': 0,
      });

      final transaction = TransactionItem.fromJson({
        'id': 9,
        'account': null,
        'category': {
          'id': 1,
          'name': 'Transport',
          'type': 'expense',
          'icon': null,
          'is_active': 1,
        },
        'type': 'expense',
        'amount': '35000',
        'transaction_date': '2026-06-28',
        'note': 'Ojek',
        'attachment_path': null,
      });

      expect(category.isActive, isFalse);
      expect(transaction.account, isNull);
      expect(transaction.category?.name, 'Transport');
      expect(transaction.amount, 35000);
      expect(transaction.transactionDate, DateTime(2026, 6, 28));
    });
  });
}
