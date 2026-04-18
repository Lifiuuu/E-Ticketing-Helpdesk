import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/auth/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Username: ${auth.username ?? '-'}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Role: ${auth.role}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Set Admin'),
                const SizedBox(width: 8),
                Switch(value: auth.role == 'admin', onChanged: (v) => auth.setRole(v ? 'admin' : 'user')),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                auth.logout();
                context.go('/login');
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
