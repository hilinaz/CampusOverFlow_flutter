import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/user_repository.dart';
import '../states/user_state.dart';
import '../models/user_model.dart';

final userRepositoryProvider =
    Provider<UserRepository>((ref) => UserRepository());

class UserController extends StateNotifier<UserState> {
  final UserRepository _repository;
  String? _authToken;
  String _searchQuery = '';
  List<User>? _cachedUsers;
  DateTime? _lastFetchTime;
  static const _cacheDuration = Duration(minutes: 5);

  UserController(this._repository) : super(const UserState.initial());

  void setAuthToken(String token) {
    _authToken = token;
    // Fetch users immediately when auth token is set
    fetchUsers();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    // If there are cached users, filter them immediately
    if (_cachedUsers != null) {
      state = UserState.success(
        users: _filterUsers(_cachedUsers!, query),
        searchQuery: query,
      );
    } else {
      // Otherwise, keep current state or refetch if necessary
      state = state.when(
        initial: () => state,
        loading: () => state,
        success: (users, _) => UserState.success(
          users: _filterUsers(users, query),
          searchQuery: query,
        ),
        error: (msg) => state,
      );
    }
  }

  Future<void> fetchUsers() async {
    if (_authToken == null) return;

    // Return cached data if it's still valid and not searching
    if (_cachedUsers != null &&
        _lastFetchTime != null &&
        _searchQuery.isEmpty) {
      final now = DateTime.now();
      if (now.difference(_lastFetchTime!) < _cacheDuration) {
        state = UserState.success(
          users: _filterUsers(_cachedUsers!, _searchQuery),
          searchQuery: _searchQuery,
        );
        return;
      }
    }

    state = const UserState.loading();
    try {
      final users = await _repository.fetchUsers(_authToken!);
      _cachedUsers = users; // Cache the fetched users
      _lastFetchTime = DateTime.now(); // Record fetch time
      state = UserState.success(
          users: _filterUsers(users, _searchQuery), searchQuery: _searchQuery);
    } catch (e) {
      state = UserState.error(e.toString());
    }
  }

  Future<void> deleteUser(int userId) async {
    if (_authToken == null) return;
    state = const UserState.loading(); // Indicate loading for the action
    try {
      await _repository.deleteUser(_authToken!, userId);
      // After deletion, clear cache and refetch users to get updated list
      _cachedUsers = null;
      _lastFetchTime = null;
      await fetchUsers();
    } catch (e) {
      state = UserState.error(e.toString());
    }
  }

  List<User> _filterUsers(List<User> users, String query) {
    if (query.isEmpty) return users;
    final lowerQuery = query.toLowerCase();
    return users.where((user) {
      final fullName = user.fullName.toLowerCase();
      final profession = user.profession?.toLowerCase() ?? '';
      return fullName.contains(lowerQuery) || profession.contains(lowerQuery);
    }).toList();
  }
}

final userControllerProvider =
    StateNotifierProvider<UserController, UserState>((ref) {
  final repo = ref.watch(userRepositoryProvider);
  return UserController(repo);
});
