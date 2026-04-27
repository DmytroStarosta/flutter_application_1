import 'package:flutter/material.dart';
import 'package:flutter_application_1/domain/validators.dart';
import 'package:flutter_application_1/logic/cubits/auth_cubit.dart';
import 'package:flutter_application_1/logic/cubits/auth_state.dart';
import 'package:flutter_application_1/widgets/custom_button.dart';
import 'package:flutter_application_1/widgets/custom_text_field.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onRegisterPressed() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().register(
            _nameController.text.trim(),
            _emailController.text.trim(),
            _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          // Якщо завантаження закінчилось, помилок немає і дані введено — успіх
          if (!state.isLoading && 
              state.errorMessage == null && 
              _emailController.text.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Registration Successful!')),
            );
            Navigator.pushReplacementNamed(context, '/login');
          } 
          // Якщо є повідомлення про помилку
          else if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00B8FC), Color(0xFF079AF7)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
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
                      validator: (v) => AppValidators.validateConfirmPassword(
                        v,
                        _passwordController.text,
                      ),
                    ),
                    const SizedBox(height: 24),
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        if (state.isLoading) {
                          return const CircularProgressIndicator(
                            color: Colors.white,
                          );
                        }
                        return CustomButton(
                          text: 'Register',
                          onPressed: _onRegisterPressed,
                        );
                      },
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/login'),
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
