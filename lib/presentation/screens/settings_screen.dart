import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:projectmobile/core/providers/auth_provider.dart';
import 'package:projectmobile/core/providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        children: [
          // === Tampilan ===
          const _SectionHeader(title: 'Tampilan'),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text('Mode Gelap'),
            subtitle: Text(isDark ? 'Aktif' : 'Nonaktif'),
            value: isDark,
            onChanged: (v) {
              if (v) {
                ref.read(themeModeProvider.notifier).setDark();
              } else {
                ref.read(themeModeProvider.notifier).setLight();
              }
            },
          ),

          const Divider(),

          // === Akun ===
          const _SectionHeader(title: 'Akun'),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Lihat Profil'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/profile'),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Keluar', style: TextStyle(color: Colors.red)),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Keluar Akun?', style: TextStyle(fontWeight: FontWeight.bold)),
                  content: const Text('Apakah Anda yakin ingin keluar dari aplikasi? Anda harus login kembali untuk mengakses tiket Anda.'),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  actions: [
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('Batal'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: const Text('Keluar'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                ref.read(authNotifierProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              }
            },
          ),

          const Divider(),

          // === Tentang ===
          const _SectionHeader(title: 'Tentang'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('E-Ticketing Helpdesk'),
            subtitle: Text('Versi 2.0.0 — DIV Teknik Informatika, Universitas Airlangga'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
