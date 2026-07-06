import 'dart:io';
import 'package:flutter/material.dart';
import 'package:projectmobile/data/models/ticket_attachment_model.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
/// Widget grid thumbnail attachment untuk Detail Tiket.
/// Menampilkan daftar attachment dalam grid 3-kolom; tap untuk full-screen viewer.
class AttachmentGrid extends StatelessWidget {
  final List<TicketAttachmentModel> attachments;

  const AttachmentGrid({super.key, required this.attachments});

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lampiran (${attachments.length})',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
          ),
          itemCount: attachments.length,
          itemBuilder: (context, index) {
            final att = attachments[index];
            return GestureDetector(
              onTap: () => _openAttachment(context, att),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildThumbnail(att),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildThumbnail(TicketAttachmentModel att) {
    final name = att.fileName?.toLowerCase() ?? '';
    final isImage = name.endsWith('.png') || name.endsWith('.jpg') || name.endsWith('.jpeg');
    
    if (isImage) {
      return Image.network(
        att.fileUrl,
        fit: BoxFit.cover,
        loadingBuilder: (ctx, child, progress) {
          if (progress == null) return child;
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        },
        errorBuilder: (ctx, _, __) => Container(
          color: Colors.grey.shade200,
          child: const Icon(Icons.broken_image, color: Colors.grey),
        ),
      );
    }
    
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
              att.fileName ?? 'File',
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

  Future<void> _openAttachment(BuildContext context, TicketAttachmentModel att) async {
    final name = att.fileName?.toLowerCase() ?? '';
    final isImage = name.endsWith('.png') || name.endsWith('.jpg') || name.endsWith('.jpeg');
    
    if (isImage) {
      _openFullScreen(context, att.fileUrl, att.fileName);
    } else {
      _downloadAndOpenFile(context, att);
    }
  }

  Future<void> _downloadAndOpenFile(BuildContext context, TicketAttachmentModel att) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await http.get(Uri.parse(att.fileUrl));
      
      if (!context.mounted) return;
      Navigator.of(context).pop(); // Tutup loading dialog

      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final fileName = att.fileName ?? 'document_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final file = File('${dir.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);
        
        final result = await OpenFilex.open(file.path);
        if (result.type != ResultType.done && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tidak dapat membuka file: ${result.message}')),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal mendownload file')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Tutup loading dialog jika error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
    }
  }


  void _openFullScreen(BuildContext context, String url, String? name) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: Text(name ?? 'Lampiran', style: const TextStyle(color: Colors.white)),
        ),
        body: Center(
          child: InteractiveViewer(
            child: Image.network(
              url,
              fit: BoxFit.contain,
              errorBuilder: (ctx, _, __) =>
                  const Icon(Icons.broken_image, color: Colors.white, size: 64),
            ),
          ),
        ),
      ),
    ));
  }
}
