import 'api_service.dart';

class WaterService {
  static Future<void> logWater(String token, {int amountMl = 250}) async {
    await ApiService.post('/water/log', {'amountMl': amountMl}, token: token);
  }

  static Future<Map<String, dynamic>> getStats(String token) async {
    final response = await ApiService.get('/water/stats', token: token);
    return response['data'];
  }
}
