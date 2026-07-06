import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:projectmobile/data/providers/provider.dart';
import 'notification_service.dart';

/// Handler untuk notifikasi yang diterima saat app TERMINATED (mati total).
/// HARUS berupa top-level function (tidak boleh di dalam class).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('FCM background message: ${message.messageId}');
  debugPrint('Title: ${message.notification?.title}');
  debugPrint('Body: ${message.notification?.body}');
}

class FcmService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final SupabaseClient _supabase;
  final Ref? ref;

  FcmService(this._supabase, {this.ref});

  /// Inisialisasi FCM — dipanggil sekali di main() setelah Firebase.initializeApp()
  Future<void> initialize() async {
    await _requestPermission();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Handle notifikasi saat app di FOREGROUND
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('FCM foreground message: ${message.notification?.title}');
      if (message.notification != null) {
        showLocalNotification(
          title: message.notification!.title ?? 'Notifikasi',
          body: message.notification!.body ?? '',
          payload: message.data['ticket_id'],
        );
      }
      
      // Invalidate stream agar UI / badge merah di dashboard terupdate secara real-time
      if (ref != null) {
        ref!.invalidate(notificationsStreamProvider);
      }
    });

    // Handle tap notifikasi saat app di BACKGROUND
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('FCM notification tapped (background): ${message.data}');
    });

    await refreshAndSaveToken();

    _messaging.onTokenRefresh.listen((newToken) async {
      debugPrint('FCM token refreshed');
      await _saveTokenToSupabase(newToken);
    });
  }

  Future<void> _requestPermission() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint('FCM permission status: ${settings.authorizationStatus}');
    } catch (e) {
      debugPrint('Error requesting FCM permission: $e');
    }
  }

  /// Ambil FCM token device dan simpan ke tabel profiles di Supabase
  Future<void> refreshAndSaveToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        debugPrint('FCM Token obtained');
        await _saveTokenToSupabase(token);
      }
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
    }
  }

  /// Simpan FCM token ke kolom fcm_token di tabel profiles
  Future<void> _saveTokenToSupabase(String token) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;
      await _supabase
          .from('profiles')
          .update({'fcm_token': token})
          .eq('id', user.id);
      debugPrint('FCM token saved for user ${user.id}');
    } catch (e) {
      debugPrint('Error saving FCM token: $e');
    }
  }

  /// Hapus FCM token dari Supabase saat user logout
  Future<void> clearToken() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;
      await _supabase
          .from('profiles')
          .update({'fcm_token': null})
          .eq('id', user.id);
      await _messaging.deleteToken();
      debugPrint('FCM token cleared');
    } catch (e) {
      debugPrint('Error clearing FCM token: $e');
    }
  }
}
