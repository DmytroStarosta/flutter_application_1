class UserModel {
  final String fullName;
  final String email;
  final String password;

  const UserModel({
    required this.fullName,
    required this.email,
    required this.password,
  });

  // Додаємо цей метод для зручного оновлення полів у Cubit
  UserModel copyWith({
    String? fullName,
    String? email,
    String? password,
  }) {
    return UserModel(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'password': password,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      fullName: (json['fullName'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      password: (json['password'] as String?) ?? '',
    );
  }
}
