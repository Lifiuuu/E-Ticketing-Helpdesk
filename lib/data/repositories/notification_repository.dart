import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final SupabaseClient _supabase;
  NotificationRepository(this._supabase);

  // Ambil daftar notifikasi milik user yang sedang login [cite: 82]
  Future<List<NotificationModel>> getNotifications() async {
    final response = await _supabase
        .from('notifications')
        .select()
        .eq('is_deleted', false)
        .order('created_at', ascending: false);
    
    return response.map((json) => NotificationModel.fromJson(json)).toList();
  }

  // Tandai notifikasi sudah dibaca
  Future<void> markAsRead(String notificationId) async {
    await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId);
  }

  // Tandai semua notifikasi user ini sudah dibaca
  Future<void> markAllAsRead() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', user.id)
        .eq('is_read', false);
  }

  // Hapus notifikasi (archive/delete)
  Future<void> deleteNotification(String notificationId) async {
    await _supabase
        .from('notifications')
        .update({'is_deleted': true})
        .eq('id', notificationId);
  }

  // Hapus beberapa notifikasi sekaligus
  Future<void> deleteMultipleNotifications(List<String> notificationIds) async {
    if (notificationIds.isEmpty) return;
    await _supabase
        .from('notifications')
        .update({'is_deleted': true})
        .inFilter('id', notificationIds);
  }

  // Hapus semua notifikasi milik user ini
  Future<void> deleteAllNotifications() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    await _supabase
        .from('notifications')
        .update({'is_deleted': true})
        .eq('user_id', user.id);
  }

  // Realtime stream for notifications belonging to a specific user
  Stream<List<NotificationModel>> getNotificationsStream(String userId) {
    final stream = _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId);
        
    return stream.map((event) {
      final list = (event as List)
          // Filter data secara lokal karena Supabase Stream hanya mengizinkan 1 filter .eq
          .where((json) => json['is_deleted'] == false || json['is_deleted'] == null)
          .map((json) => NotificationModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
      // Sort by createdAt descending (newest first)
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }
}