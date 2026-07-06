import 'package:flutter/material.dart';
import 'package:projectmobile/data/models/ticket_attachment_model.dart';
import 'package:url_launcher/url_launcher.dart';

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
      final uri = Uri.parse(att.fileUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tidak dapat membuka file ini')),
          );
        }
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
