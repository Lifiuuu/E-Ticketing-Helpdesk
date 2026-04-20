import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtl = TextEditingController(); // Gunakan Email
  final _passwordCtl = TextEditingController();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Memanggil fungsi login asli dari Notifier
    final success = await ref.read(authNotifierProvider.notifier).login(
      _emailCtl.text.trim(),
      _passwordCtl.text,
    );

    debugPrint('=== HASIL TOMBOL LOGIN: $success ===');

    if (success) {
      if (!mounted) return;
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen for auth errors and show SnackBar from provider
    ref.listen<String?>(authNotifierProvider.select((s) => s.error), (prev, next) {
      if (next != null && next.isNotEmpty) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next)));
        ref.read(authNotifierProvider.notifier).clearError();
      }
    });

    // Pantau status loading dari provider
    final isLoading = ref.watch(authNotifierProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('E-Ticketing'), centerTitle: true),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    'Login',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailCtl,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordCtl,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (v) => (v == null || v.length < 6) ? 'Minimal 6 karakter' : null,
                  ),
                  const SizedBox(height: 20),
                  isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(onPressed: _submit, child: const Text('Login')),
                  const SizedBox(height: 12),
                  TextButton(onPressed: () => context.go('/register'), child: const Text('Belum punya akun? Register')),
                  TextButton(onPressed: () => context.go('/reset'), child: const Text('Lupa Password?')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}