import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:jbsfintech/features/accounts/domain/account.dart';
import 'package:jbsfintech/features/accounts/presentation/accounts_screen.dart';
import 'package:jbsfintech/features/auth/presentation/login_screen.dart';
import 'package:jbsfintech/features/categories/domain/category.dart';
import 'package:jbsfintech/features/shared/providers.dart';
import 'package:jbsfintech/features/transactions/presentation/transaction_form_screen.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID');
  });

  Widget wrapWithMaterialApp(Widget child) {
    return ProviderScope(child: MaterialApp(home: child));
  }

  testWidgets('Login validation appears for empty fields', (tester) async {
    await tester.pumpWidget(wrapWithMaterialApp(const LoginScreen()));

    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Masuk'));
    await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
    await tester.pump();

    expect(find.text('Email wajib diisi'), findsOneWidget);
    expect(find.text('Password wajib diisi'), findsOneWidget);
  });

  testWidgets('Transaction type switch filters category options', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          accountsProvider.overrideWith(
            (ref) async => const [
              Account(
                id: 1,
                name: 'Dana',
                type: 'ewallet',
                initialBalance: 0,
                totalIncome: 0,
                totalExpense: 0,
                balance: 0,
                isActive: true,
              ),
            ],
          ),
          categoriesProvider.overrideWith(
            (ref) async => const [
              Category(
                id: 1,
                name: 'Gaji',
                type: 'income',
                icon: 'salary',
                isActive: true,
              ),
              Category(
                id: 2,
                name: 'Transport',
                type: 'expense',
                icon: 'transport',
                isActive: true,
              ),
            ],
          ),
        ],
        child: const MaterialApp(home: TransactionFormScreen()),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Pemasukan'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('transaction-category-dropdown')));
    await tester.pumpAndSettle();

    expect(find.text('Gaji'), findsWidgets);
    expect(find.text('Transport'), findsNothing);
  });

  testWidgets('Accounts screen renders empty state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [accountsProvider.overrideWith((ref) async => const [])],
        child: const MaterialApp(home: AccountsScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Akun tidak ditemukan'), findsOneWidget);
    expect(
      find.text('Coba ubah kata kunci atau tambahkan akun baru.'),
      findsOneWidget,
    );
  });
}
