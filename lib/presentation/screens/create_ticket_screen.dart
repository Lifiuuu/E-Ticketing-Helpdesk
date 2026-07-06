import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:projectmobile/core/providers/auth_provider.dart';
import 'package:projectmobile/data/providers/provider.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

const int _maxAttachments = 5;

class CreateTicketScreen extends ConsumerStatefulWidget {
  const CreateTicketScreen({super.key});

  @override
  ConsumerState<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends ConsumerState<CreateTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtl = TextEditingController();
  final _descCtl = TextEditingController();
  bool _loading = false;

  // Multi-attachment support (maks. 5 file)
  final List<File> _attachmentFiles = [];

  // Untuk Helpdesk/Admin: dropdown pilih pelapor (user)
  String? _selectedReporterId;

  @override
  void dispose() {
    _titleCtl.dispose();
    _descCtl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = ref.read(authNotifierProvider);
    final role = auth.role.toLowerCase();
    final isHelpdeskOrAdmin = role == 'helpdesk' || role == 'admin';

    // Helpdesk/Admin WAJIB pilih pelapor
    if (isHelpdeskOrAdmin && (_selectedReporterId == null || _selectedReporterId!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih pelapor terlebih dahulu')),
      );
      return;
    }

    setState(() => _loading = true);
    
    try {
      final repo = ref.read(ticketRepoProvider);
      await repo.createTicket(
        _titleCtl.text.trim(),
        _descCtl.text.trim(),
        reporterId: isHelpdeskOrAdmin ? _selectedReporterId : null,
        attachments: _attachmentFiles,
      );

      ref.invalidate(ticketsStreamProvider);

      if (!mounted) return;
      context.go('/tickets');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickAttachment() async {
    if (_attachmentFiles.length >= _maxAttachments) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maksimal 5 lampiran per tiket')),
      );
      return;
    }
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blue),
              title: const Text('Kamera (Ambil Foto)'),
              onTap: () async {
                Navigator.pop(ctx);
                final ImagePicker picker = ImagePicker();
                final XFile? image = await picker.pickImage(source: ImageSource.camera);
                if (image != null) {
                  setState(() {
                    if (_attachmentFiles.length < _maxAttachments) {
                      _attachmentFiles.add(File(image.path));
                    }
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder, color: Colors.blue),
              title: const Text('File / Galeri'),
              onTap: () async {
                Navigator.pop(ctx);
                final result = await FilePicker.pickFiles(
                  allowMultiple: true,
                  type: FileType.any,
                );
                if (result != null && result.paths.isNotEmpty) {
                  setState(() {
                    for (final path in result.paths) {
                      if (path != null && _attachmentFiles.length < _maxAttachments) {
                        _attachmentFiles.add(File(path));
                      }
                    }
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _removeAttachment(int index) {
    setState(() => _attachmentFiles.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);
    final role = auth.role.toLowerCase();
    final isHelpdeskOrAdmin = role == 'helpdesk' || role == 'admin';

    return Scaffold(
      appBar: AppBar(title: const Text('Buat Tiket')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === Dropdown Pelapor (hanya untuk Helpdesk/Admin) ===
              if (isHelpdeskOrAdmin) ...[
                const Text('Pilih Pelapor *', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                ref.watch(userListForDropdownProvider).when(
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => Text('Gagal memuat daftar user: $e',
                      style: const TextStyle(color: Colors.red)),
                  data: (users) {
                    if (users.isEmpty) {
                      return const Text('Tidak ada user terdaftar',
                          style: TextStyle(color: Colors.grey));
                    }
                    return DropdownButtonFormField<String>(
                      value: _selectedReporterId,
                      decoration: const InputDecoration(
                        hintText: 'Pilih user pelapor...',
                        border: OutlineInputBorder(),
                      ),
                      items: users
                          .map((u) => DropdownMenuItem<String>(
                                value: u.id,
                                child: Text(u.fullName ?? u.id),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedReporterId = v),
                      validator: (_) =>
                          (_selectedReporterId == null || _selectedReporterId!.isEmpty)
                              ? 'Pilih pelapor terlebih dahulu'
                              : null,
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],

              // === Judul Tiket ===
              TextFormField(
                controller: _titleCtl,
                decoration: const InputDecoration(
                  labelText: 'Judul Tiket',
                  hintText: 'Ringkasan masalah...',
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),

              // === Deskripsi ===
              TextFormField(
                controller: _descCtl,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  hintText: 'Jelaskan masalah secara detail...',
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              // === Attachment Section ===
              Row(
                children: [
                  const Text('Lampiran', style: TextStyle(fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Text(
                    '${_attachmentFiles.length}/$_maxAttachments',
                    style: TextStyle(
                      color: _attachmentFiles.length >= _maxAttachments
                          ? Colors.red
                          : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.attach_file),
                    onPressed: _attachmentFiles.length < _maxAttachments
                        ? _pickAttachment
                        : null,
                    tooltip: 'Pilih File (Gambar, PDF, Docx)',
                  ),
                ],
              ),

              // Grid preview attachment yang dipilih
              if (_attachmentFiles.isNotEmpty) ...[
                const SizedBox(height: 8),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                  ),
                  itemCount: _attachmentFiles.length,
                  itemBuilder: (ctx, index) {
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _buildFilePreview(_attachmentFiles[index]),
                        ),
                        Positioned(
                          top: 2,
                          right: 2,
                          child: GestureDetector(
                            onTap: () => _removeAttachment(index),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(2),
                              child: const Icon(Icons.close, color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
              ],

              const SizedBox(height: 16),
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submit,
                        child: const Text('Kirim Tiket'),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
  // Fungsi bantu untuk menampilkan preview file (gambar atau dokumen)
  Widget _buildFilePreview(File file) {
    final path = file.path.toLowerCase();
    if (path.endsWith('.png') || path.endsWith('.jpg') || path.endsWith('.jpeg')) {
      return Image.file(file, fit: BoxFit.cover);
    }
    // Jika bukan gambar, tampilkan icon generic
    return Container(
      color: Colors.grey.shade200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.insert_drive_file, color: Colors.grey, size: 32),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              file.path.split('/').last,
              style: const TextStyle(fontSize: 10, color: Colors.black54),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
