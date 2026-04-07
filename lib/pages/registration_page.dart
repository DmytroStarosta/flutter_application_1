import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/models/user_model.dart';
import 'package:flutter_application_1/data/repositories/auth_repository.dart';
import 'package:flutter_application_1/data/repositories/local_auth_repository.dart';
import 'package:flutter_application_1/data/services/conectivity_service.dart';
import 'package:flutter_application_1/domain/validators.dart';
import 'package:flutter_application_1/widgets/custom_button.dart';
import 'package:flutter_application_1/widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final AuthRepository _authRepository = LocalAuthRepository();
  final ConnectivityService _connectivityService = ConnectivityService();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    final bool hasInternet = await _connectivityService.hasConnection();

    if (!mounted) return;

    if (!hasInternet) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration requires an internet connection!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final newUser = UserModel(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      await _authRepository.register(newUser);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration Successful!')),
      );

      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF00B8FC), Color(0xFF079AF7)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.person_add_outlined,
                      size: 80,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 40),
                    CustomTextField(
                      label: 'Full Name',
                      icon: Icons.person,
                      controller: _nameController,
                      validator: AppValidators.validateName,
                    ),
                    CustomTextField(
                      label: 'E-mail',
                      icon: Icons.email,
                      controller: _emailController,
                      validator: AppValidators.validateEmail,
                    ),
                    CustomTextField(
                      label: 'Password',
                      icon: Icons.lock,
                      isPassword: true,
                      controller: _passwordController,
                      validator: AppValidators.validatePassword,
                    ),
                    CustomTextField(
                      label: 'Confirm Password',
                      icon: Icons.lock_clock_outlined,
                      isPassword: true,
                      controller: _confirmPasswordController,
                      validator: (value) =>
                          AppValidators.validateConfirmPassword(
                        value,
                        _passwordController.text,
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Register',
                      onPressed: _handleRegister,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: const Text(
                        'Already have an account? Login',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
