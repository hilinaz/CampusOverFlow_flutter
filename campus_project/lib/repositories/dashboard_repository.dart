import 'package:dio/dio.dart';
import '../config/api_config.dart';

class DashboardRepository {
  final Dio _dio;
  final String _baseUrl = ApiConfig.baseUrl;

  DashboardRepository({Dio? dio}) : _dio = dio ?? Dio();

  Future<Map<String, int>> getDashboardStats(String authToken) async {
    try {
      final responses = await Future.wait([
        _dio.get(
          '$_baseUrl/users/getUserStats',
          options: Options(
            headers: {
              'Authorization': 'Bearer $authToken',
            },
          ),
        ),
        _dio.get(
          '$_baseUrl/question/countQuestions',
          options: Options(
            headers: {
              'Authorization': 'Bearer $authToken',
            },
          ),
        ),
        _dio.get(
          '$_baseUrl/answers/stats',
          options: Options(
            headers: {
              'Authorization': 'Bearer $authToken',
            },
          ),
        ),
      ]);

      return {
        'totalUsers': responses[0].data['totalUsers'] ?? 0,
        'totalQuestions': responses[1].data['totalQuestions'] ?? 0,
        'totalAnswers': responses[2].data['totalAnswers'] ?? 0,
      };
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Failed to fetch dashboard stats');
    }
  }
}
