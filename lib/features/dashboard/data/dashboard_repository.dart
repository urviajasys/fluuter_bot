import '../../../core/network/api_client.dart';
import '../domain/dashboard_snapshot.dart';

class DashboardRepository {
  DashboardRepository({ApiClient? client}) : _client = client ?? const ApiClient();

  final ApiClient _client;

  Future<DashboardSnapshot> fetchDashboard() async {
    final data = await _client.getJson('/api/dashboard');
    return DashboardSnapshot.fromMap(data);
  }

  Future<void> toggleBot(bool enabled) async {
    await _client.postJson('/api/bot/toggle', {'enabled': enabled});
  }

  Future<void> updateRisk(Map<String, dynamic> payload) async {
    await _client.postJson('/api/bot/config', payload);
  }

  Future<Map<String, dynamic>> runBotCycle() {
    return _client.postJson('/api/bot/run-cycle', {});
  }

  Future<void> saveBrokerCredentials(Map<String, dynamic> payload) async {
    await _client.postJson('/api/broker/credentials', payload);
  }

  Future<Map<String, dynamic>> testBrokerSession() {
    return _client.postJson('/api/broker/session/test', {});
  }

  Future<Map<String, dynamic>> evaluateSignal(Map<String, dynamic> payload) {
    return _client.postJson('/api/strategy/evaluate', payload);
  }
}
