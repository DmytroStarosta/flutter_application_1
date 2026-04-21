import 'package:flutter_application_1/data/models/user_model.dart';
import 'package:flutter_application_1/data/repositories/local_auth_repository.dart';
import 'package:flutter_application_1/data/services/api_service.dart';
import 'package:flutter_application_1/data/services/conectivity_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserModel user;
  AuthAuthenticated(this.user);
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

class AuthCubit extends Cubit<AuthState> {
  final ApiService _api = ApiService();
  final ConnectivityService _connectivity = ConnectivityService();
  final LocalAuthRepository _authRepo = LocalAuthRepository();

  AuthCubit() : super(AuthInitial());

  Future<void> login(String email, String password) async {
    try {
      emit(AuthLoading());

      // 1. Check Internet
      final bool hasInternet = await _connectivity.hasConnection();
      if (!hasInternet) {
        emit(AuthError('No internet connection!'));
        return;
      }

      // 2. API Login
      final userMap = await _api.loginUser(email, password);

      if (userMap != null) {
        final user = UserModel.fromJson(userMap);

        // 3. Save to Local Repository (Auto-login logic)
        await _authRepo.login(email, password);

        emit(AuthAuthenticated(user));
      } else {
        emit(AuthError('Invalid credentials!'));
      }
    } catch (e) {
      emit(AuthError('Login failed: ${e.toString()}'));
    }
  }
}
