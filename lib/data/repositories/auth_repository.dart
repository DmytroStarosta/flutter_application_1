import 'package:flutter_application_1/data/models/user_model.dart';

abstract class AuthRepository {
  Future<void> register(UserModel user);

  Future<bool> login(String email, String password);

  Future<UserModel?> getUserData();

  Future<void> logout();
}
