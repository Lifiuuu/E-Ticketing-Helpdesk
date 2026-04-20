import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:projectmobile/core/providers/auth_provider.dart';
import 'package:projectmobile/core/providers/theme_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ambil data profile dari provider
    final auth = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50))),
            const SizedBox(height: 20),
            Text('Nama Lengkap: ${auth.username ?? '-'}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Email: ${auth.user?.email ?? '-'}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Role: ${auth.role}', style: const TextStyle(fontSize: 16, color: Colors.blueGrey)),
            const Spacer(),
            // Theme mode switch
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Light'),
                const SizedBox(width: 8),
                Consumer(
                  builder: (context, ref, _) {
                    final mode = ref.watch(themeModeProvider);
                    final isDark = mode == ThemeMode.dark;
                    return Switch(
                      value: isDark,
                      onChanged: (v) {
                        if (v) {
                          ref.read(themeModeProvider.notifier).setDark();
                        } else {
                          ref.read(themeModeProvider.notifier).setLight();
                        }
                      },
                    );
                  },
                ),
                const SizedBox(width: 8),
                const Text('Dark'),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                ref.read(authNotifierProvider.notifier).logout();
                context.go('/login');
              },
              child: const Text('Keluar Aplikasi', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}