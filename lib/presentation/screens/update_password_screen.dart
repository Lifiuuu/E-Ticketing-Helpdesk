import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UpdatePasswordScreen extends ConsumerStatefulWidget {
  const UpdatePasswordScreen({super.key});

  @override
  ConsumerState<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends ConsumerState<UpdatePasswordScreen> {
  final _passwordCtl = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // Debug logs to inspect why reset callback might not navigate correctly
    debugPrint('Entered UpdatePasswordScreen');
    final session = Supabase.instance.client.auth.currentSession;
    final user = Supabase.instance.client.auth.currentUser;
    debugPrint('Supabase currentSession in UpdatePasswordScreen: $session');
    debugPrint('Supabase currentUser in UpdatePasswordScreen: ${user?.id}');
  }

  Future<void> _submit() async {
    if (_passwordCtl.text.length < 6) return;
    setState(() => _loading = true);

    try {
      // INI KODE SAKTI UNTUK MENGGANTI PASSWORD
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: _passwordCtl.text),
      );
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password berhasil diubah!')),
      );
      context.go('/dashboard'); // Langsung masuk ke aplikasi
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('E-Ticketing'), centerTitle: true),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                Text(
                  'Buat Password Baru',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text('Silakan masukkan password baru Anda.'),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordCtl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password Baru'),
                ),
                const SizedBox(height: 20),
                _loading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(onPressed: _submit, child: const Text('Simpan Password')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}