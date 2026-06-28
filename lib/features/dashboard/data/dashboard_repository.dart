import '../../../core/network/api_client.dart';
import '../../../core/utils/json_parsers.dart';
import '../domain/dashboard_data.dart';

class DashboardRepository {
  DashboardRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<DashboardData> fetchDashboard() async {
    final envelope = await _apiClient.get('/dashboard');
    return DashboardData.fromJson(JsonParsers.asMap(envelope.data));
  }
}
