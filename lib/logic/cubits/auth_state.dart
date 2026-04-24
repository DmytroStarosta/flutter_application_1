import 'package:flutter_application_1/data/models/user_model.dart';

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? errorMessage;
  final bool isLogout;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.isLogout = false,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? errorMessage,
    bool? isLogout,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isLogout: isLogout ?? this.isLogout,
    );
  }
}
