import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

/// Singleton plugin instance, diinisialisasi di main()
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// Android notification channel
const AndroidNotificationChannel _channel = AndroidNotificationChannel(
  'eticketing_channel', // id
  'E-Ticketing Helpdesk', // name
  description: 'Notifikasi perubahan status tiket dan komentar baru',
  importance: Importance.high,
);

/// Inisialisasi plugin — dipanggil di main() sebelum runApp()
Future<void> initLocalNotifications() async {
  const initSettingsAndroid = AndroidInitializationSettings('@mipmap/launcher_icon');
  const initSettingsDarwin = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );
  const initSettings = InitializationSettings(
    android: initSettingsAndroid,
    iOS: initSettingsDarwin,
    macOS: initSettingsDarwin,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      // Tap pada notifikasi: navigasi sudah di-handle via GoRouter di NotificationBanner
      debugPrint('Notification tapped: ${response.payload}');
    },
  );

  // Buat Android channel
  final androidPlugin = flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
  await androidPlugin?.createNotificationChannel(_channel);
}

/// Request permission notifikasi (Android 13+, iOS)
Future<void> requestNotificationPermission() async {
  try {
    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();

    final iosPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);
  } catch (e) {
    debugPrint('Error requesting notification permission: $e');
  }
}

/// Tampilkan local notification
Future<void> showLocalNotification({
  required String title,
  required String body,
  String? payload,
}) async {
  try {
    const androidDetails = AndroidNotificationDetails(
      'eticketing_channel',
      'E-Ticketing Helpdesk',
      channelDescription: 'Notifikasi perubahan status tiket dan komentar baru',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const notifDetails = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notifDetails,
      payload: payload,
    );
  } catch (e) {
    debugPrint('Error showing local notification: $e');
  }
}