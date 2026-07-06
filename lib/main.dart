import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 

import 'package:projectmobile/core/providers/router_provider.dart';
import 'core/theme/theme.dart';
import 'core/providers/theme_provider.dart';
import 'core/notification/notification_service.dart';
import 'core/notification/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://xfnwlwbdlepsunsvkfen.supabase.co', 
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inhmbndsd2JkbGVwc3Vuc3ZrZmVuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY1MDQ0OTMsImV4cCI6MjA5MjA4MDQ5M30.Af7X_v9flCkssenbQ5wNh1m8soWuVuHACDH0rWPu5II', 
  );

  // Inisialisasi Firebase
  await Firebase.initializeApp();

  // Daftarkan background message handler SEBELUM runApp()
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Inisialisasi flutter_local_notifications + buat Android channel
  await initLocalNotifications();

  // Request izin notifikasi (Android 13+ & iOS)
  await requestNotificationPermission();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    final routerConfig = ref.watch(routerProvider);

    return MaterialApp.router(
        title: 'E-Ticketing Helpdesk',
        theme: AppThemes.light,
        darkTheme: AppThemes.dark,
        themeMode: ref.watch(themeModeProvider),
        
        routerConfig: routerConfig, 
        
        builder: (context, child) {
          return child ?? const SizedBox.shrink();
        },
      );
  }
}