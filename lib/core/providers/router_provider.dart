import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:projectmobile/core/providers/auth_provider.dart';
import 'package:projectmobile/core/providers/supabase_provider.dart';
import 'package:projectmobile/presentation/screens/splash_screen.dart';
import 'package:projectmobile/presentation/screens/login_screen.dart';
import 'package:projectmobile/presentation/screens/register_screen.dart';
import 'package:projectmobile/presentation/screens/reset_password_screen.dart';
import 'package:projectmobile/presentation/screens/dashboard_screen.dart';
import 'package:projectmobile/presentation/screens/profile_screen.dart';
import 'package:projectmobile/presentation/screens/tickets_list_screen.dart';
import 'package:projectmobile/presentation/screens/create_ticket_screen.dart';
import 'package:projectmobile/presentation/screens/ticket_detail_screen.dart';
import 'package:projectmobile/presentation/screens/update_password_screen.dart';
import 'package:projectmobile/presentation/screens/notifications_screen.dart';
import 'package:projectmobile/presentation/screens/tracking_ticket_screen.dart';
import 'package:projectmobile/presentation/screens/user_management_screen.dart';
import 'package:projectmobile/presentation/screens/settings_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {

  return GoRouter(
    initialLocation: '/splash',
    
    redirect: (context, state) {
      final auth = ref.read(authNotifierProvider);
      final session = ref.read(supabaseProvider).auth.currentSession;
      final isLoggedIn = session != null;
      final role = auth.role.toLowerCase();
      final path = state.location; 

      debugPrint('=== LAPORAN SATPAM GOROUTER ===');
      debugPrint('Tujuan: $path | Status Login: $isLoggedIn | Role: $role');
      debugPrint('===============================');

      if (path == '/splash') return null; 

      final isAuthPage = path == '/login' || path == '/register' || path == '/reset';
      final uri = Uri.parse(path);
      final isUpdatePasswordPage =
          path.startsWith('/reset-callback') ||
          uri.queryParameters.containsKey('code') ||
          uri.queryParameters['type'] == 'recovery' ||
          uri.queryParameters.containsKey('access_token') ||
          uri.queryParameters.containsKey('token');

      if (isUpdatePasswordPage) {
        final qs = uri.hasQuery ? '?${uri.query}' : '';
        return '/reset-callback$qs';
      }

      if (!isLoggedIn && !isAuthPage) {
        return '/login';
      }

      if (isLoggedIn && isAuthPage) {
        return '/dashboard';
      }

      // Blokir /users untuk non-admin
      if (path == '/users' && role != 'admin') {
        return '/dashboard';
      }

      return null; 
    },

    // ==========================================
    // DAFTAR RUTE HALAMAN
    // ==========================================
    routes: [
      // Root route to allow GoRouter to match deep-links delivered to '/?code=...'
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/reset',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-callback', 
        builder: (context, state) => const UpdatePasswordScreen(),
      ),
      GoRoute(
        path: '/dashboard', 
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/tickets',
        builder: (context, state) => const TicketsListScreen(),
      ),
      GoRoute(
        path: '/create-ticket',
        // FR-005/006/007: semua role dapat akses; role check dilakukan di dalam screen
        builder: (context, state) => const CreateTicketScreen(),
      ),
      GoRoute(
        path: '/ticket/:id', 
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return TicketDetailScreen(id: id);
        },
      ),
      // FR-010/011: Tracking/history tiket
      GoRoute(
        path: '/ticket/:id/tracking',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return TrackingTicketScreen(ticketId: id);
        },
      ),
      // FR-007: Admin — kelola pengguna
      GoRoute(
        path: '/users',
        builder: (context, state) => const UserManagementScreen(),
      ),
      // Settings screen
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});

// no extension needed; use `state.location` for current path