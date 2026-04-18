import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_router.dart';
import 'core/theme/theme.dart';
import 'core/auth/auth_provider.dart';
import 'core/notification/notification_service.dart';
import 'core/notification/notification_banner.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NotificationService.instance),
      ],
      child: MaterialApp.router(
        title: 'E-Ticketing Helpdesk',
        theme: AppThemes.light,
        darkTheme: AppThemes.dark,
        routerConfig: router,
        builder: (context, child) {
          return Stack(
            children: [
              if (child != null) child,
              const NotificationBanner(),
            ],
          );
        },
      ),
    );
  }
}
