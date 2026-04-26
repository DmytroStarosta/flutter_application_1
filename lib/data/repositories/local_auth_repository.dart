import 'dart:convert';
import 'package:flutter_application_1/data/models/user_model.dart';
import 'package:flutter_application_1/data/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalAuthRepository implements AuthRepository {
  static final LocalAuthRepository _instance = LocalAuthRepository._internal();
  factory LocalAuthRepository() => _instance;
  LocalAuthRepository._internal();

  static const String _usersKey = 'registered_users_list';
  static const String _currentUserEmailKey = 'user_email';

  @override
  Future<void> register(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    final List<UserModel> users = await _getAllUsers();

    users.removeWhere((u) => u.email == user.email);
    users.add(user);

    final encoded = jsonEncode(users.map((u) => u.toJson()).toList());
    await prefs.setString(_usersKey, encoded);
  }

  @override
  Future<bool> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final users = await _getAllUsers();

    final bool canLogin = users.any(
      (u) => u.email == email && u.password == password,
    );

    if (canLogin) {
      await prefs.setString(_currentUserEmailKey, email);
      return true;
    }
    return false;
  }

  @override
  Future<UserModel?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_currentUserEmailKey);
    final users = await _getAllUsers();

    if (email == null) return null;
    try {
      return users.firstWhere((u) => u.email == email);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserEmailKey);
  }

  Future<List<UserModel>> _getAllUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final String? json = prefs.getString(_usersKey);
    
    if (json == null || json.isEmpty) return [];

    try {
      final List<dynamic> decoded = jsonDecode(json) as List<dynamic>;

      return decoded.map((i) {
        return UserModel.fromJson(i as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      return [];
    }
  }
}
