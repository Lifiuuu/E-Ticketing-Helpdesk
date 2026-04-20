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

final routerProvider = Provider<GoRouter>((ref) {

  return GoRouter(
    initialLocation: '/splash',
    
    redirect: (context, state) {
      // ---> PINDAHKAN KE SINI & GANTI JADI ref.read <---
      // Satpam hanya mengecek KTP saat ada yang mau lewat, bukan diamati tiap detik
      final auth = ref.read(authNotifierProvider);
      // Use Supabase session to determine logged-in state so users aren't
      // treated as logged-out when their `profiles` row is missing.
      final session = ref.read(supabaseProvider).auth.currentSession;
      final isLoggedIn = session != null;
      final role = auth.role.toLowerCase();
      final path = state.location; 

      debugPrint('=== LAPORAN SATPAM GOROUTER ===');
      debugPrint('Tujuan: $path | Status Login: $isLoggedIn | Role: $role');
      debugPrint('===============================');

      if (path == '/splash') return null; 

      final isAuthPage = path == '/login' || path == '/register' || path == '/reset';
      // Some platforms may deliver the deep-link as '/?code=...' instead of
      // '/reset-callback?code=...'. Treat any incoming URI that contains
      // a Supabase reset `code` query parameter as the update-password page.
      final uri = Uri.parse(path);
      // Treat a number of possible deep-link query parameters from Supabase
      // as the update-password flow. Some platforms deliver the link as
      // '/?type=recovery&...' or include 'access_token'/'token' instead of
      // a 'code' key.
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

      if (isLoggedIn) {
        final isPetugas = role == 'admin' || role == 'helpdesk';
        if (path == '/create-ticket' && isPetugas) {
          return '/tickets'; 
        }
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
        builder: (context, state) => const CreateTicketScreen(),
      ),
      GoRoute(
        path: '/ticket/:id', 
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return TicketDetailScreen(id: id);
        },
      ),
    ],
  );
});

// no extension needed; use `state.location` for current path