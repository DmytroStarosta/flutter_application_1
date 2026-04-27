import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/models/user_model.dart';
import 'package:flutter_application_1/data/services/conectivity_service.dart';
import 'package:flutter_application_1/logic/cubits/auth_cubit.dart';
import 'package:flutter_application_1/logic/cubits/auth_state.dart';
import 'package:flutter_application_1/widgets/custom_button.dart';
import 'package:flutter_application_1/widgets/profile_header.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF079AF7),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.isLogout) {
            Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
          }
        },
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00B8FC), Color(0xFF079AF7)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: LayoutBuilder(builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    final user = state.user;
                    if (user == null) return const SizedBox.shrink();
                    return StreamBuilder<List<ConnectivityResult>>(
                      stream: ConnectivityService().connectivityStream,
                      builder: (context, snap) {
                        final isOff = 
                        snap.data?.contains(ConnectivityResult.none) ?? 
                        true;
                        return _buildContent(context, user, isOff);
                      },
                    );
                  },
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, UserModel user, bool isOffline) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: IntrinsicHeight(
          child: Column(
            children: [
              ProfileHeader(
                user: user,
                isOffline: isOffline,
                onEdit: () => _showEditDialog(context, user),
              ),
              const SizedBox(height: 40),
              _buildOption(Icons.settings, 'Settings'),
              _buildOption(Icons.notifications, 'Notifications'),
              _buildOption(Icons.history, 'Sensor History'),
              const Spacer(),
              const SizedBox(height: 40),
              CustomButton(
                text: 'Log Out',
                onPressed: () => _showLogoutDialog(context),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption(IconData icon, String title) => Container(
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

  void _showEditDialog(BuildContext context, UserModel user) {
    final ctrl = TextEditingController(text: user.fullName);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(controller: ctrl, 
        decoration: const InputDecoration(hintText: 'New name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), 
          child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (ctrl.text.isNotEmpty) {
                context.read<AuthCubit>().updateName(ctrl.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), 
          child: const Text('Cancel')),
          TextButton(
            onPressed: () => context.read<AuthCubit>().logout(),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
