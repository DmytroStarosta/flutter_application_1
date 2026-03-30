class UserModel {
  final String fullName;
  final String email;
  final String password;

  const UserModel({
    required this.fullName,
    required this.email,
    required this.password,
  });

  Map<String, String> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'password': password,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      fullName: (map['fullName'] as String?) ?? '',
      email: (map['email'] as String?) ?? '',
      password: (map['password'] as String?) ?? '',
    );
  }
}
