import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:projectmobile/core/providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Beri jeda 2-3 detik sesuai keinginanmu
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;

    // Jika app dibuka lewat deep-link reset dari Supabase, arahkan ke
    // halaman Update Password sambil mempertahankan query string.
    final location = GoRouter.of(context).location;
    final uri = Uri.parse(location);
    final isUpdatePasswordPage =
        location.startsWith('/reset-callback') ||
        uri.queryParameters.containsKey('code') ||
        uri.queryParameters['type'] == 'recovery' ||
        uri.queryParameters.containsKey('access_token') ||
        uri.queryParameters.containsKey('token');

    if (isUpdatePasswordPage) {
      final qs = uri.hasQuery ? '?${uri.query}' : '';
      context.go('/reset-callback$qs');
      return;
    }

    // Cek status login setelah jeda selesai
    final auth = ref.read(authNotifierProvider);
    if (auth.username != null) {
      context.go('/dashboard');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('lib/assets/logo_e-ticketing.png', width: 96),
            const SizedBox(height: 16),
            const Text('E-Ticketing Helpdesk', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const CircularProgressIndicator(), // Indikator loading
          ],
        ),
      ),
    );
  }
}