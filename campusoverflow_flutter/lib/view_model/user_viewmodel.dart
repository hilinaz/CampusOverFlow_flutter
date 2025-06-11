import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../config/api_config.dart'; // Assuming you have an ApiConfig for the base URL

class UserViewModel extends ChangeNotifier {
  final String authToken;
  List<User> _users = [];
  String _searchQuery = ''; // New: search query
  bool _isLoading = false;
  String? _error;

  UserViewModel({required this.authToken});

  List<User> get users {
    if (_searchQuery.isEmpty) {
      return _users;
    } else {
      return _users.where((user) {
        final fullName = user.fullName.toLowerCase();
        final profession = user.profession?.toLowerCase() ?? '';
        final query = _searchQuery.toLowerCase();
        return fullName.contains(query) || profession.contains(query);
      }).toList();
    }
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery; // New: public getter for searchQuery

  void setSearchQuery(String query) {
    _searchQuery = query;
    debugPrint('Search query set to: $_searchQuery'); // Debug print
    notifyListeners();
  }

  Future<void> fetchUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final Uri uri = Uri.parse(
        '${ApiConfig.baseUrl}/users/getAllUserNamesAndProfessions'); // Corrected endpoint

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer $authToken', // Include auth token if required
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> userJsonList =
            responseData['users']; // Access the 'users' key
        _users = userJsonList.map((json) => User.fromJson(json)).toList();
        _error = null;
      } else {
        _error = 'Failed to load users: ${response.statusCode}';
        // Optionally decode error message from response body if available
        // final body = jsonDecode(response.body);
        // _error = body['message'] ?? _error;
      }
    } on Exception catch (e) {
      _error = 'Error fetching users: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteUser(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final Uri uri = Uri.parse(
        '${ApiConfig.baseUrl}/users/$userId'); // Assuming DELETE /users/:userid

    try {
      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        _users
            .removeWhere((user) => user.id == userId); // Remove from local list
        _error = null;
        debugPrint('User $userId deleted successfully.');
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        _error = errorData['message'] ??
            errorData['msg'] ??
            'Failed to delete user: ${response.statusCode}';
        debugPrint('Failed to delete user $userId: $_error');
        return false;
      }
    } on Exception catch (e) {
      _error = 'Error deleting user: $e';
      debugPrint('Exception during user deletion: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // TODO: Add methods for other user operations (e.g., deleteUser, updateUser) if needed.
}
