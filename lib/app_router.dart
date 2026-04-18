import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/register_screen.dart';
import 'presentation/screens/reset_password_screen.dart';
import 'presentation/screens/dashboard_screen.dart';
import 'presentation/screens/profile_screen.dart';
import 'presentation/screens/tickets_list_screen.dart';
import 'presentation/screens/create_ticket_screen.dart';
import 'presentation/screens/ticket_detail_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/profile',
  routes: [
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/reset',
      name: 'reset',
      builder: (context, state) => const ResetPasswordScreen(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/tickets',
      name: 'tickets',
      builder: (context, state) => const TicketsListScreen(),
    ),
    GoRoute(
      path: '/create-ticket',
      name: 'createTicket',
      builder: (context, state) => const CreateTicketScreen(),
    ),
    GoRoute(
      path: '/ticket/:id',
      name: 'ticketDetail',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
        return TicketDetailScreen(id: id);
      },
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
);
