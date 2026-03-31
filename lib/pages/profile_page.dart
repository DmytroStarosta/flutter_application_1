import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/models/user_model.dart';
import 'package:flutter_application_1/data/repositories/auth_repository.dart';
import 'package:flutter_application_1/data/repositories/local_auth_repository.dart';
import 'package:flutter_application_1/widgets/custom_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthRepository _authRepository = LocalAuthRepository();
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await _authRepository.getUserData();
    if (!mounted) return;
    setState(() {
      _user = user;
    });
  }

  Future<void> _editName() async {
    if (_user == null) return;
    final controller = TextEditingController(text: _user!.fullName);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter new name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.isNotEmpty && _user != null) {
                final updatedUser = UserModel(
                  fullName: controller.text.trim(),
                  email: _user!.email,
                  password: _user!.password,
                );

                await _authRepository.register(updatedUser);
                await _loadUserData();

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _handleLogout() async {
    await _authRepository.logout();
    
    if (!mounted) return;
    
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF00B8FC), Color(0xFF079AF7)],
          ),
        ),
        child: Center(
          child: _user == null
              ? const CircularProgressIndicator(color: Colors.white)
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white24,
                          child: Icon(
                            Icons.person,
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                _user?.fullName ?? 'User',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.white70,
                                size: 20,
                              ),
                              onPressed: _editName,
                            ),
                          ],
                        ),
                        Text(
                          _user?.email ?? '',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 40),
                        _buildOption(Icons.settings, 'Settings'),
                        _buildOption(Icons.notifications, 'Notifications'),
                        _buildOption(Icons.history, 'Sensor History'),
                        const SizedBox(height: 40),
                        CustomButton(text: 'Log Out', onPressed: _handleLogout),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildOption(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        trailing: const Icon(Icons.chevron_right, color: Colors.white54),
        onTap: () {},
      ),
    );
  }
}
