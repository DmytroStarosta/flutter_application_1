import 'dart:convert';

import 'package:flutter_application_1/data/models/user_model.dart';
import 'package:flutter_application_1/data/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalAuthRepository implements AuthRepository {
  static const String _usersKey = 'registered_users_list';
  static const String _currentUserEmailKey = 'user_email';

  @override
  Future<void> register(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    final String? usersJson = prefs.getString(_usersKey);
    List<UserModel> users = [];
    
    if (usersJson != null) {
      final List<dynamic> decoded = jsonDecode(usersJson) as List<dynamic>;
      users = decoded.map<UserModel>((item) {
        return UserModel.fromJson(item as Map<String, dynamic>);
      }).toList();
    }

    users.removeWhere((u) => u.email == user.email);
    users.add(user);
    
    final String encoded = jsonEncode(users.map((u) => u.toJson()).toList());
    await prefs.setString(_usersKey, encoded);
  }

  @override
  Future<bool> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final String? usersJson = prefs.getString(_usersKey);

    if (usersJson == null) return false;

    final List<dynamic> decoded = jsonDecode(usersJson) as List<dynamic>;
    final List<UserModel> users = decoded.map<UserModel>((item) {
      return UserModel.fromJson(item as Map<String, dynamic>);
    }).toList();

    final bool canLogin = users.any((u) => u.email == email && u.password == password);

    if (canLogin) {
      await prefs.setString(_currentUserEmailKey, email);
      return true;
    }
    return false;
  }

  @override
  Future<UserModel?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? currentEmail = prefs.getString(_currentUserEmailKey);
    final String? usersJson = prefs.getString(_usersKey);

    if (currentEmail == null || usersJson == null) return null;

    final List<dynamic> decoded = jsonDecode(usersJson) as List<dynamic>;
    final List<UserModel> users = decoded.map<UserModel>((item) {
      return UserModel.fromJson(item as Map<String, dynamic>);
    }).toList();

    try {
      return users.firstWhere((u) => u.email == currentEmail);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserEmailKey);
  }
}
