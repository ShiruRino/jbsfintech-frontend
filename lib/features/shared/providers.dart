import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/providers.dart';
import '../accounts/data/accounts_repository.dart';
import '../accounts/domain/account.dart';
import '../categories/data/categories_repository.dart';
import '../categories/domain/category.dart';
import '../dashboard/data/dashboard_repository.dart';
import '../dashboard/domain/dashboard_data.dart';
import '../transactions/data/transactions_repository.dart';
import '../transactions/domain/transaction_item.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>(
  (ref) => DashboardRepository(ref.watch(apiClientProvider)),
);

final accountsRepositoryProvider = Provider<AccountsRepository>(
  (ref) => AccountsRepository(ref.watch(apiClientProvider)),
);

final categoriesRepositoryProvider = Provider<CategoriesRepository>(
  (ref) => CategoriesRepository(ref.watch(apiClientProvider)),
);

final transactionsRepositoryProvider = Provider<TransactionsRepository>(
  (ref) => TransactionsRepository(ref.watch(apiClientProvider)),
);

final dashboardProvider = FutureProvider<DashboardData>(
  (ref) => ref.watch(dashboardRepositoryProvider).fetchDashboard(),
);

final accountsProvider = FutureProvider<List<Account>>(
  (ref) => ref.watch(accountsRepositoryProvider).fetchAccounts(),
);

final accountDetailProvider =
    FutureProvider.family<(Account, List<TransactionItem>), int>(
      (ref, id) => ref.watch(accountsRepositoryProvider).fetchAccountDetail(id),
    );

final categoriesProvider = FutureProvider<List<Category>>(
  (ref) => ref.watch(categoriesRepositoryProvider).fetchCategories(),
);

final categoryDetailProvider =
    FutureProvider.family<(Category, List<TransactionItem>), int>(
      (ref, id) =>
          ref.watch(categoriesRepositoryProvider).fetchCategoryDetail(id),
    );

final transactionsProvider = FutureProvider<List<TransactionItem>>(
  (ref) => ref.watch(transactionsRepositoryProvider).fetchTransactions(),
);

final transactionDetailProvider = FutureProvider.family<TransactionItem, int>(
  (ref, id) => ref.watch(transactionsRepositoryProvider).fetchTransaction(id),
);
