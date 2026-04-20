import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart';
import '../models/ticket_model.dart';
import '../models/comment_model.dart';

class TicketRepository {
  final SupabaseClient _supabase;
  TicketRepository(this._supabase);

  // FR-005 & FR-006: Ambil semua tiket yang diizinkan oleh RLS 
  Future<List<TicketModel>> getTickets() async {
    final response = await _supabase
        .from('tickets')
        .select()
        .order('created_at', ascending: false);
    
    return response.map((json) => TicketModel.fromJson(json)).toList();
  }

  // Ambil tiket milik user tertentu
  Future<List<TicketModel>> getTicketsForUser(String userId) async {
    final response = await _supabase
        .from('tickets')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List).map((json) => TicketModel.fromJson(Map<String, dynamic>.from(json))).toList();
  }

  // Ambil tiket yang di-assign ke helpdesk tertentu
  Future<List<TicketModel>> getTicketsAssignedToHelpdesk(String helpdeskId) async {
    final response = await _supabase
        .from('tickets')
        .select()
        .eq('assigned_to', helpdeskId)
        .order('created_at', ascending: false);

    return (response as List).map((json) => TicketModel.fromJson(Map<String, dynamic>.from(json))).toList();
  }

  // FR-005: Membuat tiket baru (User) [cite: 63]
  Future<void> createTicket(String title, String description, {String? imageUrl}) async {
    final userId = _supabase.auth.currentUser!.id;
    // Insert ticket and get inserted row (to obtain its id)
    final inserted = await _supabase.from('tickets').insert({
      'user_id': userId,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'status': 'Open',
    }).select().maybeSingle();

    final ticketId = inserted != null ? inserted['id']?.toString() : null;

    // Notify all admins about new ticket (include ticket_id when available)
    try {
      final adminProfiles = await _supabase
          .from('profiles')
          .select()
          .eq('role', 'Admin');
      
      for (final admin in (adminProfiles as List)) {
        final adminId = admin['id']?.toString();
        if (adminId != null && adminId.isNotEmpty) {
          await _supabase.from('notifications').insert({
            'user_id': adminId,
            'title': 'Tiket baru masuk',
            'message': 'Tiket "$title" telah dibuat oleh user',
            'ticket_id': ticketId,
            'is_read': false,
          });
        }
      }
    } catch (e) {
      debugPrint('Error notifying admins about new ticket: $e');
    }
  }

  // Upload file to Supabase Storage and return public URL
  Future<String> uploadAttachment(File file) async {
    final userId = _supabase.auth.currentUser!.id;
    final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}_${p.basename(file.path)}';
    final bucket = 'tickets';
    final path = 'attachments/$fileName';

    final bytes = await file.readAsBytes();
    await _supabase.storage.from(bucket).uploadBinary(path, bytes);

    final res = _supabase.storage.from(bucket).getPublicUrl(path);
    return res;
  }

  // FR-006: Update Status & Assign (Admin/Helpdesk) [cite: 75, 76]
  Future<void> updateTicketStatus(String ticketId, String status) async {
    await _supabase.from('tickets').update({'status': status}).eq('id', ticketId);

    // Create notification for ticket owner and assignee about status change
    final ticket = await _supabase.from('tickets').select().eq('id', ticketId).maybeSingle();
    if (ticket == null) return;
    final ownerId = ticket['user_id']?.toString();
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

  Future<void> assignTicket(String ticketId, String petugasId) async {
    await _supabase.from('tickets').update({'assigned_to': petugasId}).eq('id', ticketId);

    // Create notification for ticket owner and new assignee
    final ticket = await _supabase.from('tickets').select().eq('id', ticketId).maybeSingle();
    if (ticket == null) return;
    final ownerId = ticket['user_id']?.toString();
    final title = 'Tiket ditugaskan';
    final message = 'Tiket "${ticket['title'] ?? ''}" telah ditugaskan ke user $petugasId';

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

  // FR-005: Memberikan komentar (User/Helpdesk) [cite: 67]
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
    final ownerId = ticket['user_id']?.toString();
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
    final response = await _supabase.from('tickets').select().eq('id', ticketId).maybeSingle();
    if (response == null) return null;
    return TicketModel.fromJson(Map<String, dynamic>.from(response));
  }
}