import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projectmobile/core/providers/auth_provider.dart';
import 'package:projectmobile/data/providers/provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtl;
  late TextEditingController _phoneCtl;
  bool _loading = false;
  File? _avatarFile; // file lokal sebelum diupload

  @override
  void initState() {
    super.initState();
    final auth = ref.read(authNotifierProvider);
    _nameCtl = TextEditingController(text: auth.username ?? '');
    _phoneCtl = TextEditingController(text: auth.phoneNumber ?? '');
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _phoneCtl.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final result = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Kamera'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (result == null) return;
    final picked = await picker.pickImage(source: result, maxWidth: 800, imageQuality: 85);
    if (picked == null) return;
    setState(() => _avatarFile = File(picked.path));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final repo = ref.read(authRepoProvider);

      // Upload avatar jika ada file baru
      if (_avatarFile != null) {
        await repo.uploadAvatar(_avatarFile!);
      }

      // Update nama & telepon
      await repo.updateProfile(
        _nameCtl.text.trim(),
        phoneNumber: _phoneCtl.text.trim().isEmpty ? null : _phoneCtl.text.trim(),
      );

      // Refresh state auth agar username terbaru langsung tampil
      // Trigger re-read dari Supabase
      // Cukup invalidate agar notifier reload profile
      ref.invalidate(profileProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil disimpan')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // === Avatar ===
              GestureDetector(
                onTap: _pickAvatar,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 52,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: _avatarFile != null
                          ? FileImage(_avatarFile!) as ImageProvider
                          : (auth.avatarUrl != null
                              ? NetworkImage(auth.avatarUrl!) as ImageProvider
                              : null),
                      child: (_avatarFile == null && auth.avatarUrl == null)
                          ? const Icon(Icons.person, size: 52, color: Colors.grey)
                          : null,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                auth.role,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                auth.user?.email ?? '—',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),

              const SizedBox(height: 24),

              // === Nama Lengkap ===
              TextFormField(
                controller: _nameCtl,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 12),

              // === Email (read-only) ===
              TextFormField(
                initialValue: auth.user?.email ?? '—',
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                  suffixIcon: Icon(Icons.lock_outline, size: 16, color: Colors.grey),
                ),
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 12),

              // === Nomor Telepon ===
              TextFormField(
                controller: _phoneCtl,
                decoration: const InputDecoration(
                  labelText: 'Nomor Telepon',
                  hintText: 'Opsional',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),

              // === Simpan ===
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _save,
                        icon: const Icon(Icons.save_outlined),
                        label: const Text('Simpan Perubahan'),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}