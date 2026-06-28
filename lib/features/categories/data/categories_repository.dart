import '../../../core/network/api_client.dart';
import '../../../core/utils/json_parsers.dart';
import '../../transactions/domain/transaction_item.dart';
import '../domain/category.dart';

class CategoriesRepository {
  CategoriesRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Category>> fetchCategories() async {
    final envelope = await _apiClient.get('/categories');
    return JsonParsers.listOfMap(envelope.data).map(Category.fromJson).toList();
  }

  Future<(Category, List<TransactionItem>)> fetchCategoryDetail(int id) async {
    final envelope = await _apiClient.get('/categories/$id');
    final data = JsonParsers.asMap(envelope.data);
    final category = Category.fromJson(JsonParsers.asMap(data['category']));
    final transactions = JsonParsers.listOfMap(
      data['latest_transactions'],
    ).map(TransactionItem.fromJson).toList();
    return (category, transactions);
  }

  Future<void> createCategory({
    required String name,
    required String type,
    required String? icon,
    required bool isActive,
  }) async {
    await _apiClient.post(
      '/categories',
      data: {'name': name, 'type': type, 'icon': icon, 'is_active': isActive},
    );
  }

  Future<void> updateCategory({
    required int id,
    required String name,
    required String type,
    required String? icon,
    required bool isActive,
  }) async {
    await _apiClient.put(
      '/categories/$id',
      data: {'name': name, 'type': type, 'icon': icon, 'is_active': isActive},
    );
  }

  Future<void> deleteCategory(int id) async {
    await _apiClient.delete('/categories/$id');
  }
}
