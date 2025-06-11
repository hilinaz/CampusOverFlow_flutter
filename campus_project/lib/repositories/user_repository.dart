import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../config/api_config.dart';

class UserRepository {
  final Dio _dio;

  UserRepository({Dio? dio}) : _dio = dio ?? Dio();

  Future<List<User>> fetchUsers(String authToken) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/users/getAllUserNamesAndProfessions',
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        }),
      );
      final data = response.data;
      final List<dynamic> userJsonList = data['users'];
      return userJsonList.map((json) => User.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load users');
    }
  }

  Future<void> deleteUser(String authToken, int userId) async {
    try {
      await _dio.delete(
        '${ApiConfig.baseUrl}/users/$userId',
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        }),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to delete user');
    }
  }
}
