import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:projectmobile/data/providers/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';


class CreateTicketScreen extends ConsumerStatefulWidget {
  const CreateTicketScreen({super.key});

  @override
  ConsumerState<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends ConsumerState<CreateTicketScreen> {
  // ... (form variables letak di sini, biarkan sama)
  final _formKey = GlobalKey<FormState>();
  final _titleCtl = TextEditingController();
  final _descCtl = TextEditingController();
  bool _loading = false;
  File? _attachmentFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    
    // PANGGIL REPOSITORY ASLI
    try {
      final repo = ref.read(ticketRepoProvider);
      String? imageUrl;
      if (_attachmentFile != null) {
        try {
          imageUrl = await repo.uploadAttachment(_attachmentFile!);
          if (imageUrl.isEmpty) throw Exception('Upload gagal: URL kosong');
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal meng-upload lampiran: $e')));
          setState(() => _loading = false);
          return;
        }
      }

      try {
        await repo.createTicket(
          _titleCtl.text.trim(),
          _descCtl.text.trim(),
          imageUrl: imageUrl,
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal membuat tiket: $e')));
        setState(() => _loading = false);
        return;
      }
      
      // Beri tahu provider list agar merefresh datanya
      ref.invalidate(ticketsStreamProvider); 

      if (!mounted) return;
      // Arahkan secara deterministik ke daftar tiket setelah submit
      context.go('/tickets');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickAttachment(ImageSource source) async {
    final result = await _picker.pickImage(source: source, maxWidth: 1600, imageQuality: 80);
    if (result == null) return;
    setState(() {
      _attachmentFile = File(result.path);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Tiket')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleCtl,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtl,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 4,
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Attachment'),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.photo_camera),
                    onPressed: () => _pickAttachment(ImageSource.camera),
                    tooltip: 'Camera',
                  ),
                  IconButton(
                    icon: const Icon(Icons.photo_library),
                    onPressed: () => _pickAttachment(ImageSource.gallery),
                    tooltip: 'Gallery',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_attachmentFile != null) ...[
                Image.file(_attachmentFile!, height: 160, fit: BoxFit.cover),
                const SizedBox(height: 8),
              ],
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(onPressed: _submit, child: const Text('Submit')),
            ],
          ),
        ),
      ),
    );
  }
}
