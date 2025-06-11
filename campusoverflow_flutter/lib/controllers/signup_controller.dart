import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/signup_repository.dart';
import '../models/user_model.dart';
import 'package:flutter/foundation.dart';

final signupControllerProvider =
    StateNotifierProvider<SignupController, AsyncValue<User?>>((ref) {
  return SignupController(ref.watch(signupRepositoryProvider));
});

final signupRepositoryProvider = Provider<SignupRepository>((ref) {
  return SignupRepository();
});

class SignupController extends StateNotifier<AsyncValue<User?>> {
  final SignupRepository _repository;

  SignupController(this._repository) : super(const AsyncValue.data(null));

  Future<void> signup({
    required String username,
    required String firstName,
    required String lastName,
    required String profession,
    required String email,
    required String password,
  }) async {
    try {
      // Set loading state
      state = const AsyncValue.loading();
      debugPrint('SignupController: Starting signup process');

      // Create user object
      final user = User(
        id: 0, // This will be set by the server
        username: username,
        firstName: firstName,
        lastName: lastName,
        profession: profession,
        email: email,
        password: password,
      );

      // Attempt to sign up
      final result = await _repository.signup(user);

      debugPrint('SignupController: Signup successful');
      state = AsyncValue.data(result);
    } catch (e, stackTrace) {
      debugPrint('SignupController: Error during signup');
      debugPrint('Error: $e');
      debugPrint('Stack trace: $stackTrace');

      // Handle the error state with the specific error message
      state = AsyncValue.error(e, stackTrace);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}
