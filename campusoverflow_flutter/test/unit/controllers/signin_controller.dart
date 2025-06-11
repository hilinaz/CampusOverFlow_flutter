import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/signin_repository.dart';
import 'package:flutter/foundation.dart';

final signinRepositoryProvider = Provider<SigninRepository>((ref) {
  return SigninRepository();
});

final signinControllerProvider =
    StateNotifierProvider<SigninController, AsyncValue<Map<String, dynamic>?>>(
        (ref) {
  return SigninController(ref.watch(signinRepositoryProvider));
});

class SigninController
    extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  final SigninRepository _repository;

  SigninController(this._repository) : super(const AsyncValue.data(null));

  Future<void> signin({
    required String email,
    required String password,
  }) async {
    try {
      // Set loading state
      state = const AsyncValue.loading();
      debugPrint('SigninController: Starting signin process');

      // Attempt to sign in
      final result = await _repository.signin(
        email: email,
        password: password,
      );

      debugPrint('SigninController: Signin successful');
      state = AsyncValue.data(result);
    } catch (e, stackTrace) {
      debugPrint('SigninController: Error during signin');
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
