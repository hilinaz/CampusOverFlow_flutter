import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/signup_viewmodel.dart';
import '../models/user_model.dart';
import 'QuestionsScreen.dart'; // <-- Import LandingScreen here

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _viewModel = SignupViewModel();

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
      final user = User(
        firstname: _firstNameController.text.trim(),
        lastname: _lastNameController.text.trim(),
        username: _usernameController.text.trim(),
        profession: _professionController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final success = await _viewModel.signup(user);

      if (success && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const QuestionsScreen()),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_viewModel.error ?? 'Signup failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<SignupViewModel>(
        builder: (context, viewModel, child) {
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
                                color: Color(
                                    0xFFFCF8F6), // Light cream-like background
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
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
                                        validator: (val) => _validateNotEmpty(
                                            val, 'First Name'),
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
                                        validator: (val) => _validateNotEmpty(
                                            val, 'Profession'),
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
                                              _passwordVisible =
                                                  !_passwordVisible;
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
                                        onPressed: viewModel.isLoading
                                            ? null
                                            : _onRegisterPressed,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFFFF8500),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: viewModel.isLoading
                                            ? const CircularProgressIndicator(
                                                color: Colors.white)
                                            : const Text(
                                                'Sign Up',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                      ),
                                      const SizedBox(height: 30),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          _buildSocialIcon(
                                            icon: Icons.facebook,
                                            color: Colors.blue[800]!,
                                          ),
                                          const SizedBox(width: 20),
                                          _buildSocialIcon(
                                            icon: Icons.email,
                                            color: Colors.redAccent,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 30),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
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
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Color(0xFFFF8500), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Color(0xFFFF8500), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: suffixIcon,
      ),
      validator: validator,
      onChanged: (_) => setState(() {}), // To update button state on input
    );
  }

  static Widget _buildSocialIcon(
      {required IconData icon, required Color color}) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(10),
      child: Icon(icon, color: Colors.white),
    );
  }
}
