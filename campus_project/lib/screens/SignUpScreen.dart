import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_project/controllers/signup_controller.dart';
import 'package:campus_project/states/signup_state.dart';
import 'package:campus_project/models/user_model.dart';
import 'QuestionsScreen.dart';
import 'Dashboard.dart'; // Add import for DashboardScreen

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for each input field
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _professionController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _autoValidate = false;

  // State variables to toggle password visibility
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    ref.listenManual(signupControllerProvider, (previous, next) {
      next.when(
        data: (data) {
          if (data == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Signup failed: No data received'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          try {
            final user = data;

            if (user == null ||
                user.id == null ||
                user.username == null ||
                user.firstName == null ||
                user.lastName == null ||
                user.profession == null ||
                user.roleId == null ||
                user.token == null) {
              throw Exception(
                  'Invalid user data format: missing required fields or user is null');
            }

            final userFullName = '${user.firstName!} ${user.lastName!}';
            final profession = user.profession!;
            final roleId = user.roleId!;
            final token = user.token!;

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Signup successful!'),
                backgroundColor: Colors.green,
              ),
            );

            if (roleId == 1) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => DashboardScreen(
                    authToken: token,
                    userFullName: userFullName,
                    userProfession: profession,
                  ),
                ),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => QuestionsScreen(
                    authToken: token,
                    userFullName: userFullName,
                  ),
                ),
              );
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error processing response: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        loading: () {},
        error: (error, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString()),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    });
  }

  bool get _isFormValid {
    return _formKey.currentState?.validate() ?? false;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Confirm password is required';
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  String? _validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }

  Future<void> _onRegisterPressed() async {
    setState(() => _autoValidate = true);
    if (_isFormValid) {
      // Validate all required fields are present
      if (_usernameController.text.trim().isEmpty ||
          _firstNameController.text.trim().isEmpty ||
          _lastNameController.text.trim().isEmpty ||
          _professionController.text.trim().isEmpty ||
          _emailController.text.trim().isEmpty ||
          _passwordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All fields are required'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Validate password length
      if (_passwordController.text.length < 8) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password must be at least 8 characters'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      ref.read(signupControllerProvider.notifier).signup(
            username: _usernameController.text.trim(),
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            profession: _professionController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _professionController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final signupState = ref.watch(signupControllerProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.95,
      minChildSize: 0.6,
      maxChildSize: 1.0,
      expand: false,
      builder: (_, controller) {
        return Scaffold(
          backgroundColor: Colors.black.withOpacity(0.6),
          body: Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          color:
                              Color(0xFFFCF8F6), // Light cream-like background
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: SingleChildScrollView(
                          controller: controller,
                          padding: const EdgeInsets.all(24),
                          child: Form(
                            key: _formKey,
                            autovalidateMode: _autoValidate
                                ? AutovalidateMode.always
                                : AutovalidateMode.disabled,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Center(
                                  child: Text(
                                    'Sign Up',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFFF8500),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 30),
                                _buildOutlinedField(
                                  controller: _firstNameController,
                                  hint: 'First Name',
                                  validator: (val) =>
                                      _validateNotEmpty(val, 'First Name'),
                                ),
                                const SizedBox(height: 16),
                                _buildOutlinedField(
                                  controller: _lastNameController,
                                  hint: 'Last Name',
                                  validator: (val) =>
                                      _validateNotEmpty(val, 'Last Name'),
                                ),
                                const SizedBox(height: 16),
                                _buildOutlinedField(
                                  controller: _usernameController,
                                  hint: 'Username',
                                  validator: (val) =>
                                      _validateNotEmpty(val, 'Username'),
                                ),
                                const SizedBox(height: 16),
                                _buildOutlinedField(
                                  controller: _professionController,
                                  hint: 'Profession',
                                  validator: (val) =>
                                      _validateNotEmpty(val, 'Profession'),
                                ),
                                const SizedBox(height: 16),
                                _buildOutlinedField(
                                  controller: _emailController,
                                  hint: 'Email',
                                  validator: _validateEmail,
                                ),
                                const SizedBox(height: 16),
                                _buildOutlinedField(
                                  controller: _passwordController,
                                  hint: 'Password',
                                  obscure: !_passwordVisible,
                                  validator: _validatePassword,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _passwordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _passwordVisible = !_passwordVisible;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildOutlinedField(
                                  controller: _confirmPasswordController,
                                  hint: 'Confirm Password',
                                  obscure: !_confirmPasswordVisible,
                                  validator: _validateConfirmPassword,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _confirmPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _confirmPasswordVisible =
                                            !_confirmPasswordVisible;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(height: 30),
                                ElevatedButton(
                                  onPressed: signupState.maybeWhen(
                                    loading: () => null,
                                    data: (_) => _onRegisterPressed,
                                    error: (_, __) => _onRegisterPressed,
                                    orElse: () => _onRegisterPressed,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFF8500),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 5,
                                  ),
                                  child: signupState.maybeWhen(
                                    loading: () =>
                                        const CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                    data: (_) => const Text(
                                      'Register',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    error: (_, __) => const Text(
                                      'Register',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    orElse: () => const Text(
                                      'Register',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    'Already have an account? Sign In',
                                    style: TextStyle(
                                      color: Color(0xFFFF8500),
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (signupState.maybeWhen(
                loading: () => true,
                orElse: () => false,
              ))
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFFF8500),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOutlinedField({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF8500), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        suffixIcon: suffixIcon,
      ),
      validator: validator,
    );
  }
}
