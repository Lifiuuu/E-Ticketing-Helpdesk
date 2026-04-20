import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 

import 'package:projectmobile/core/providers/router_provider.dart';
import 'core/theme/theme.dart';
import 'core/providers/theme_provider.dart';
import 'core/notification/notification_banner.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://xfnwlwbdlepsunsvkfen.supabase.co', 
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inhmbndsd2JkbGVwc3Vuc3ZrZmVuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY1MDQ0OTMsImV4cCI6MjA5MjA4MDQ5M30.Af7X_v9flCkssenbQ5wNh1m8soWuVuHACDH0rWPu5II', 
  );

  runApp(const ProviderScope(child: MyApp()));
}

// 1. UBAH: Dari StatelessWidget menjadi ConsumerWidget
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // 2. UBAH: Tambahkan parameter WidgetRef ref di dalam build
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    // 3. TAMBAH: Panggil router dari Riverpod
    final routerConfig = ref.watch(routerProvider);

    return MaterialApp.router(
        title: 'E-Ticketing Helpdesk',
        theme: AppThemes.light,
        darkTheme: AppThemes.dark,
      themeMode: ref.watch(themeModeProvider),
        
        // 4. UBAH: Masukkan variabel routerConfig ke sini
        routerConfig: routerConfig, 
        
        builder: (context, child) {
          return Stack(
            children: [
              child ?? const SizedBox.shrink(),
              const NotificationBanner(),
            ],
          );
        },
      );
  }
}