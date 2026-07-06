import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart';
import '../models/ticket_model.dart';
import '../models/comment_model.dart';
import '../models/ticket_attachment_model.dart';

class TicketRepository {
  final SupabaseClient _supabase;
  TicketRepository(this._supabase);

  // FR-005 & FR-006: Ambil semua tiket yang diizinkan oleh RLS 
  Future<List<TicketModel>> getTickets() async {
    final response = await _supabase
        .from('tickets')
        .select()
        .eq('is_deleted', false)
        .order('created_at', ascending: false);
    
    return response.map((json) => TicketModel.fromJson(json)).toList();
  }

  // Ambil tiket milik user tertentu (dibuat sendiri atau dibuatkan oleh helpdesk/admin)
  Future<List<TicketModel>> getTicketsForUser(String userId) async {
    final response = await _supabase
        .from('tickets')
        .select()
        .eq('is_deleted', false)
        .or('user_id.eq.$userId,reporter_id.eq.$userId')
        .order('created_at', ascending: false);

    return (response as List).map((json) => TicketModel.fromJson(Map<String, dynamic>.from(json))).toList();
  }

  // Ambil tiket yang di-assign ke helpdesk tertentu
  Future<List<TicketModel>> getTicketsAssignedToHelpdesk(String helpdeskId) async {
    final response = await _supabase
        .from('tickets')
        .select()
        .eq('is_deleted', false)
        .eq('assigned_to', helpdeskId)
        .order('created_at', ascending: false);

    return (response as List).map((json) => TicketModel.fromJson(Map<String, dynamic>.from(json))).toList();
  }

  // FR-005: Membuat tiket baru (User) — tanpa reporter dropdown
  // FR-006/FR-007: Membuat tiket (Helpdesk/Admin) — dengan reporterId dari dropdown
  Future<void> createTicket(
    String title,
    String description, {
    String? imageUrl,
    String? reporterId,
    List<File> attachments = const [],
  }) async {
    final userId = _supabase.auth.currentUser!.id;
    // Insert ticket and get inserted row (to obtain its id)
    final inserted = await _supabase.from('tickets').insert({
      'user_id': userId,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'status': 'Open',
      // reporterId diisi jika Helpdesk/Admin yang membuat tiket atas nama user lain
      if (reporterId != null) 'reporter_id': reporterId,
    }).select().maybeSingle();

    final ticketId = inserted != null ? inserted['id']?.toString() : null;

    // Upload multi-attachments jika ada
    if (ticketId != null && attachments.isNotEmpty) {
      await uploadAttachments(ticketId, attachments);
    }

    // Notify all admins about new ticket (include ticket_id when available)
    try {
      final adminProfiles = await _supabase
          .from('profiles')
          .select()
          .eq('role', 'Admin');
      
      for (final admin in (adminProfiles as List)) {
        final adminId = admin['id']?.toString();
        // Jangan kirim notif admin ke diri sendiri jika admin yang membuat tiket
        if (adminId != null && adminId.isNotEmpty && adminId != userId) {
          await _supabase.from('notifications').insert({
            'user_id': adminId,
            'title': 'Tiket baru masuk',
            'message': 'Tiket "$title" telah dibuat',
            'ticket_id': ticketId,
            'is_read': false,
          });
        }
      }

      // Beri notifikasi ke pemilik tiket (User pelapor) bahwa tiketnya telah dibuat
      final ownerId = reporterId ?? userId;
      // Jika yang membuat adalah admin/helpdesk (ada reporterId), atau jika user membuat sendiri, beri notifikasi konfirmasi
      await _supabase.from('notifications').insert({
        'user_id': ownerId,
        'title': 'Tiket Berhasil Dibuat',
        'message': 'Tiket "$title" telah berhasil dibuat dan terdaftar di sistem.',
        'ticket_id': ticketId,
        'is_read': false,
      });

    } catch (e) {
      debugPrint('Error notifying users about new ticket: $e');
    }
  }

  // Upload multiple files to Supabase Storage dan simpan ke tabel ticket_attachments
  Future<void> uploadAttachments(String ticketId, List<File> files) async {
    final userId = _supabase.auth.currentUser!.id;
    for (final file in files) {
      try {
        final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}_${p.basename(file.path)}';
        const bucket = 'tickets';
        final path = 'attachments/$fileName';

        final bytes = await file.readAsBytes();
        await _supabase.storage.from(bucket).uploadBinary(path, bytes);
        final url = _supabase.storage.from(bucket).getPublicUrl(path);
        final fileSize = await file.length();

        await _supabase.from('ticket_attachments').insert({
          'ticket_id': ticketId,
          'file_url': url,
          'file_name': p.basename(file.path),
          'file_size': fileSize,
        });
      } catch (e) {
        debugPrint('Error uploading attachment: $e');
      }
    }
  }

  // Ambil semua attachment untuk tiket tertentu
  Future<List<TicketAttachmentModel>> getAttachments(String ticketId) async {
    try {
      final response = await _supabase
          .from('ticket_attachments')
          .select()
          .eq('ticket_id', ticketId)
          .order('created_at', ascending: true);

      return (response as List)
          .map((json) => TicketAttachmentModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } catch (e) {
      debugPrint('Error fetching attachments: $e');
      return [];
    }
  }

  // Upload single file to Supabase Storage and return public URL (legacy support)
  Future<String> uploadAttachment(File file) async {
    final userId = _supabase.auth.currentUser!.id;
    final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}_${p.basename(file.path)}';
    const bucket = 'tickets';
    final path = 'attachments/$fileName';

    final bytes = await file.readAsBytes();
    await _supabase.storage.from(bucket).uploadBinary(path, bytes);

    final res = _supabase.storage.from(bucket).getPublicUrl(path);
    return res;
  }

  // FR-006: Update Status (Admin/Helpdesk)
  Future<void> updateTicketStatus(String ticketId, String status) async {
    await _supabase.from('tickets').update({'status': status}).eq('id', ticketId);

    // Create notification for ticket owner and assignee about status change
    final ticket = await _supabase.from('tickets').select().eq('id', ticketId).maybeSingle();
    if (ticket == null) return;
    final ownerId = ticket['reporter_id']?.toString() ?? ticket['user_id']?.toString();
    final assigneeId = ticket['assigned_to']?.toString();
    final title = 'Status tiket diperbarui';
    final message = 'Tiket "${ticket['title'] ?? ''}" diubah status menjadi $status';

    final recipients = <String>{};
    if (ownerId != null && ownerId.isNotEmpty) recipients.add(ownerId);
    if (assigneeId != null && assigneeId.isNotEmpty) recipients.add(assigneeId);

    for (final rid in recipients) {
      await _supabase.from('notifications').insert({
        'user_id': rid,
        'title': title,
        'message': message,
        'ticket_id': ticketId,
        'is_read': false,
      });
    }
  }

  // FR-007: Assign helpdesk ke tiket
  Future<void> assignTicket(String ticketId, String petugasId) async {
    await _supabase.from('tickets').update({
      'assigned_to': petugasId,
    }).eq('id', ticketId);

    // Ambil nama petugas
    final petugasProfile = await _supabase.from('profiles').select('full_name').eq('id', petugasId).maybeSingle();
    final petugasName = (petugasProfile != null && petugasProfile['full_name'] != null)
        ? petugasProfile['full_name'].toString()
        : 'Helpdesk';

    // Create notification for ticket owner and new assignee
    final ticket = await _supabase.from('tickets').select().eq('id', ticketId).maybeSingle();
    if (ticket == null) return;
    final ownerId = ticket['reporter_id']?.toString() ?? ticket['user_id']?.toString();
    const title = 'Tiket ditugaskan';
    final message = 'Tiket "${ticket['title'] ?? ''}" telah ditugaskan ke $petugasName';

    final recipients = <String>{};
    if (ownerId != null && ownerId.isNotEmpty) recipients.add(ownerId);
    if (petugasId.isNotEmpty) recipients.add(petugasId);

    for (final rid in recipients) {
      await _supabase.from('notifications').insert({
        'user_id': rid,
        'title': title,
        'message': message,
        'ticket_id': ticketId,
        'is_read': false,
      });
    }
  }

  // Hapus Tiket (Soft Delete) - Khusus Admin
  Future<void> deleteTicket(String ticketId) async {
    await _supabase.from('tickets').update({'is_deleted': true}).eq('id', ticketId);
  }

  // FR-005: Memberikan komentar (User/Helpdesk)
  Future<void> addComment(String ticketId, String message) async {
    final userId = _supabase.auth.currentUser!.id;
    // Insert comment
    await _supabase.from('comments').insert({
      'ticket_id': ticketId,
      'user_id': userId,
      'message': message,
    });

    // Create notifications for relevant parties
    final ticket = await _supabase.from('tickets').select().eq('id', ticketId).maybeSingle();
    if (ticket == null) return;
    final ownerId = ticket['reporter_id']?.toString() ?? ticket['user_id']?.toString();
    final assigneeId = ticket['assigned_to']?.toString();

    final recipients = <String>{};
    // Notify ticket owner if they didn't comment
    if (ownerId != null && ownerId.isNotEmpty && ownerId != userId) recipients.add(ownerId);
    // Notify helpdesk assignee if they didn't comment
    if (assigneeId != null && assigneeId.isNotEmpty && assigneeId != userId) recipients.add(assigneeId);
    
    // Notify all admins about comments on any ticket
    try {
      final adminProfiles = await _supabase
          .from('profiles')
          .select()
          .eq('role', 'Admin');
      
      for (final admin in (adminProfiles as List)) {
        final adminId = admin['id']?.toString();
        if (adminId != null && adminId.isNotEmpty && adminId != userId) {
          recipients.add(adminId);
        }
      }
    } catch (e) {
      debugPrint('Error fetching admins for notification: $e');
    }

    for (final rid in recipients) {
      await _supabase.from('notifications').insert({
        'user_id': rid,
        'title': 'Komentar baru pada tiket',
        'message': message,
        'ticket_id': ticketId,
        'is_read': false,
      });
    }
  }

  // Ambil komentar untuk sebuah tiket
  Future<List<CommentModel>> getComments(String ticketId) async {
    final response = await _supabase
        .from('comments')
        .select()
        .eq('ticket_id', ticketId)
        .order('created_at', ascending: true);

    return (response as List).map((json) => CommentModel.fromJson(Map<String, dynamic>.from(json))).toList();
  }

  // Realtime stream of comments for a ticket. Emits the full list on changes.
  Stream<List<CommentModel>> getCommentsStream(String ticketId) {
    final stream = _supabase
        .from('comments')
        .stream(primaryKey: ['id'])
        .eq('ticket_id', ticketId);

    return stream.map((event) {
      // event is expected to be a List of row maps
      return event.map((json) => CommentModel.fromJson(Map<String, dynamic>.from(json))).toList();
        });
  }

  // Ambil satu tiket berdasarkan id
  Future<TicketModel?> getTicketById(String ticketId) async {
    final response = await _supabase.from('tickets').select().eq('id', ticketId).eq('is_deleted', false).maybeSingle();
    if (response == null) return null;
    return TicketModel.fromJson(Map<String, dynamic>.from(response));
  }
}