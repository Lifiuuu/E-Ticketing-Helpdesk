import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/supabase_provider.dart';

class NotificationService {
  final SupabaseClient _supabase;
  
  NotificationService(this._supabase);

  // Fungsi untuk mendengarkan notifikasi baru secara realtime
  void listenToNotifications(String userId, Function(String title, String msg) onNewNotification) {
    _supabase
        .channel('public:notifications')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            final data = payload.newRecord;
            onNewNotification(data['title'], data['message']);
          },
        )
        .subscribe();
  }
}

// Provider agar bisa diakses di main.dart atau SplashScreen
final notificationServiceProvider = Provider((ref) {
  return NotificationService(ref.watch(supabaseProvider));
});