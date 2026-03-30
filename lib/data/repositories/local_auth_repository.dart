import 'package:flutter_application_1/data/models/user_model.dart';
import 'package:flutter_application_1/data/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalAuthRepository implements AuthRepository {
  static const String _nameKey = 'user_name';
  static const String _emailKey = 'user_email';
  static const String _passKey = 'user_password';

  @override
  Future<void> register(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, user.fullName);
    await prefs.setString(_emailKey, user.email);
    await prefs.setString(_passKey, user.password);
  }

  @override
  Future<bool> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString(_emailKey);
    final savedPassword = prefs.getString(_passKey);

    return savedEmail == email && savedPassword == password;
  }

  @override
  Future<UserModel?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_nameKey);
    final email = prefs.getString(_emailKey);

    if (name != null && email != null) {
      return UserModel(fullName: name, email: email, password: '');
    }
    return null;
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
