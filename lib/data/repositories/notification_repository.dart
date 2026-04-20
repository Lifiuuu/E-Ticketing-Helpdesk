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

  // Hapus notifikasi (archive/delete)
  Future<void> deleteNotification(String notificationId) async {
    await _supabase
        .from('notifications')
        .delete()
        .eq('id', notificationId);
  }

  // Realtime stream for notifications belonging to a specific user
  Stream<List<NotificationModel>> getNotificationsStream(String userId) {
    final stream = _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId);
    return stream.map((event) {
      final list = (event as List)
          .map((json) => NotificationModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
      // Sort by createdAt descending (newest first)
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }
}