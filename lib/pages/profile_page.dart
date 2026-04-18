import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/models/user_model.dart';
import 'package:flutter_application_1/data/repositories/local_auth_repository.dart';
import 'package:flutter_application_1/data/services/api_service.dart';
import 'package:flutter_application_1/data/services/conectivity_service.dart';
import 'package:flutter_application_1/widgets/custom_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final LocalAuthRepository _authRepo = LocalAuthRepository();
  final ConnectivityService _connService = ConnectivityService();
  final ApiService _apiService = ApiService();
  late Future<UserModel?> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _syncUserData();
  }

  Future<UserModel?> _syncUserData() async {
    try {
      final apiData = await _apiService.getUserProfile();
      final localUser = await _authRepo.getUserData();
      if (localUser != null) {
        final updated = UserModel(
          fullName: apiData['fullName'] as String? ?? localUser.fullName,
          email: apiData['email'] as String? ?? localUser.email,
          password: localUser.password,
        );
        await _authRepo.register(updated);
        return updated;
      }
    } catch (_) {}
    return _authRepo.getUserData();
  }

  Future<void> _editName(UserModel user) async {
    final ctrl = TextEditingController(text: user.fullName);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: 'New name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (ctrl.text.isNotEmpty) {
                await _authRepo.register(
                  UserModel(
                    fullName: ctrl.text.trim(),
                    email: user.email,
                    password: user.password,
                  ),
                );
                setState(() => _userFuture = _authRepo.getUserData());
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _handleLogout() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _authRepo.logout();
              if (!mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (r) => false,
              );
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConnectivityResult>>(
      stream: _connService.connectivityStream,
      initialData: const [ConnectivityResult.none],
      builder: (context, snapshot) {
        final isOffline =
            snapshot.data?.contains(ConnectivityResult.none) ?? true;

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
                colors: [Color(0xFF00B8FC), Color(0xFF079AF7)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: FutureBuilder<UserModel?>(
              future: _userFuture,
              builder: (context, userSnap) {
                if (userSnap.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }
                final user = userSnap.data;
                if (user == null) {
                  return const Center(child: Text('Error loading user'));
                }
                return _buildProfile(user, isOffline);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfile(UserModel user, bool isOffline) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: SafeArea(
        child: Column(
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white24,
              child: Icon(Icons.person, size: 80, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    user.fullName,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: isOffline ? Colors.white24 : Colors.white70,
                  ),
                  onPressed: isOffline ? null : () => _editName(user),
                ),
              ],
            ),
            Text(
              user.email,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 40),
            _buildOption(Icons.settings, 'Settings'),
            _buildOption(Icons.history, 'Sensor History'),
            const SizedBox(height: 40),
            CustomButton(text: 'Log Out', onPressed: _handleLogout),
          ],
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
      ),
    );
  }
}
