import 'package:flutter_application_1/data/models/user_model.dart';
import 'package:flutter_application_1/data/repositories/local_auth_repository.dart';
import 'package:flutter_application_1/data/services/api_service.dart';
import 'package:flutter_application_1/data/services/conectivity_service.dart';
import 'package:flutter_application_1/logic/cubits/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<AuthState> {
  final ApiService _api = ApiService();
  final ConnectivityService _connectivity = ConnectivityService();
  final LocalAuthRepository _authRepo = LocalAuthRepository();

  AuthCubit() : super(const AuthState());

  Future<void> login(String email, String password) async {
    emit(state.copyWith(isLoading: true));
    try {
      if (!await _connectivity.hasConnection()) {
        throw Exception('No internet connection!');
      }

      final userMap = await _api.loginUser(email, password);
      if (userMap != null) {
        final user = UserModel.fromJson(userMap);
        await _authRepo.login(email, password);
        emit(state.copyWith(user: user, isLoading: false));
      } else {
        throw Exception('Invalid email or password!');
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> register(String name, String email, String password) async {
    emit(state.copyWith(isLoading: true));
    try {
      if (!await _connectivity.hasConnection()) {
        throw Exception('Registration requires internet!');
      }

      await _api.registerUser({
        'fullName': name,
        'email': email,
        'password': password,
      });

      final newUser = UserModel(
        fullName: name,
        email: email,
        password: password,
      );
      
      await _authRepo.register(newUser);
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> syncUserData() async {
    try {
      final apiData = await _api.getUserProfile();
      final localUser = await _authRepo.getUserData();
      
      if (localUser != null) {
        final updated = localUser.copyWith(
          fullName: apiData['fullName'] as String? ?? localUser.fullName,
          email: apiData['email'] as String? ?? localUser.email,
        );
        await _authRepo.register(updated);
        emit(state.copyWith(user: updated));
      }
    } catch (_) {
      final local = await _authRepo.getUserData();
      if (local != null) emit(state.copyWith(user: local));
    }
  }

  Future<void> updateName(String newName) async {
    if (state.user != null) {
      final updated = state.user!.copyWith(fullName: newName);
      await _authRepo.register(updated);
      emit(state.copyWith(user: updated));
    }
  }

  void logout() {
    _authRepo.logout();
    emit(const AuthState(isLogout: true));
  }
}
