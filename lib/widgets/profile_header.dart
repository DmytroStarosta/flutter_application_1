import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/models/user_model.dart';

class ProfileHeader extends StatelessWidget {
  final UserModel user;
  final bool isOffline;
  final VoidCallback onEdit;

  const ProfileHeader({
    required this.user, required this.isOffline, required this.onEdit, 
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
              onPressed: isOffline ? null : onEdit,
            ),
          ],
        ),
        Text(
          user.email,
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ],
    );
  }
}
