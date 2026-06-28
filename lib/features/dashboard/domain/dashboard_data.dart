import '../../../core/utils/json_parsers.dart';
import '../../accounts/domain/account.dart';
import '../../auth/domain/user.dart';
import '../../categories/domain/category.dart';

class DashboardData {
  const DashboardData({
    required this.user,
    required this.totalIncome,
    required this.totalExpense,
    required this.initialBalance,
    required this.totalBalance,
    required this.incomeThisMonth,
    required this.expenseThisMonth,
    required this.transactionsToday,
    required this.transactionsThisMonth,
    required this.topExpenseCategories,
    required this.accountBalances,
  });

  final User user;
  final int totalIncome;
  final int totalExpense;
  final int initialBalance;
  final int totalBalance;
  final int incomeThisMonth;
  final int expenseThisMonth;
  final int transactionsToday;
  final int transactionsThisMonth;
  final List<TopExpenseCategory> topExpenseCategories;
  final List<Account> accountBalances;

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      user: User.fromJson(JsonParsers.asMap(json['user'])),
      totalIncome: JsonParsers.toInt(json['total_income']),
      totalExpense: JsonParsers.toInt(json['total_expense']),
      initialBalance: JsonParsers.toInt(json['initial_balance']),
      totalBalance: JsonParsers.toInt(json['total_balance']),
      incomeThisMonth: JsonParsers.toInt(json['income_this_month']),
      expenseThisMonth: JsonParsers.toInt(json['expense_this_month']),
      transactionsToday: JsonParsers.toInt(json['transactions_today']),
      transactionsThisMonth: JsonParsers.toInt(json['transactions_this_month']),
      topExpenseCategories: JsonParsers.listOfMap(
        json['top_expense_categories'],
      ).map(TopExpenseCategory.fromJson).toList(),
      accountBalances: JsonParsers.listOfMap(
        json['account_balances'],
      ).map(Account.fromJson).toList(),
    );
  }
}

class TopExpenseCategory {
  const TopExpenseCategory({required this.category, required this.total});

  final Category? category;
  final int total;

  factory TopExpenseCategory.fromJson(Map<String, dynamic> json) {
    final categoryJson = JsonParsers.asMap(json['category']);
    return TopExpenseCategory(
      category: categoryJson.isEmpty ? null : Category.fromJson(categoryJson),
      total: JsonParsers.toInt(json['total']),
    );
  }
}
