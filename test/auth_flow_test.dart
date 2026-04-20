import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:projectmobile/main.dart';
import 'package:projectmobile/core/providers/auth_provider.dart';
import 'package:projectmobile/core/providers/router_provider.dart';
import 'package:projectmobile/data/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import 'package:projectmobile/data/models/profile_model.dart';
import 'package:projectmobile/presentation/screens/login_screen.dart';
import 'package:projectmobile/presentation/screens/register_screen.dart';
import 'package:projectmobile/presentation/screens/reset_password_screen.dart';
import 'package:projectmobile/presentation/screens/dashboard_screen.dart';
import 'package:projectmobile/presentation/screens/profile_screen.dart';

// Fake repository implementation used by FakeAuthNotifier (no network)
class FakeAuthRepo implements AuthRepoInterface {
  @override
  Future<supa.AuthResponse> signIn(String email, String password) async {
    throw UnimplementedError();
  }

  @override
  Future<supa.AuthResponse> signUp(String email, String password, String fullName) async {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<ProfileModel?> getMyProfile() async => null;
  @override
  Future<ProfileModel?> getProfileById(String id) async => null;
  @override
  Future<List<ProfileModel>> getHelpdeskUsers() async => [];
  @override
  Future<List<ProfileModel>> getAdminUsers() async => [];
}

class FakeAuthNotifier extends AuthNotifier {
  FakeAuthNotifier() : super(FakeAuthRepo(), null, skipInit: true);

  @override
  Future<bool> login(String email, String password) async {
    state = state.copyWith(username: 'Test User', user: null, role: 'User');
    return true;
  }

  @override
  Future<bool> register(String username, String email, String password) async {
    state = state.copyWith(username: username, role: 'User');
    return true;
  }

  @override
  Future<bool> resetPassword(String email) async {
    return true;
  }

  @override
  void logout() {
    state = AuthState();
  }
}

void main() {
  testWidgets('Auth flows: register -> login -> reset -> logout', (WidgetTester tester) async {
    final testRouter = GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
        GoRoute(path: '/register', builder: (c, s) => const RegisterScreen()),
        GoRoute(path: '/reset', builder: (c, s) => const ResetPasswordScreen()),
        GoRoute(path: '/dashboard', builder: (c, s) => const DashboardScreen()),
        GoRoute(path: '/profile', builder: (c, s) => const ProfileScreen()),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // override the auth notifier provider with our fake notifier
          authNotifierProvider.overrideWith((ref) => FakeAuthNotifier()),
          // override router to guarantee predictable navigation in tests
          routerProvider.overrideWithValue(testRouter),
        ],
        child: const MyApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Ensure we're on Login screen (AppBar title 'Login')
    expect(find.widgetWithText(AppBar, 'Login'), findsOneWidget);

    // Go to Register
    await tester.tap(find.text('Belum punya akun? Register'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Register'), findsOneWidget);

    // Fill register form
    await tester.enterText(find.widgetWithText(TextFormField, 'Username'), 'Tester');
    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'tester@example.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
    await tester.pumpAndSettle();

    // After register, should navigate back to login and show a success SnackBar
    expect(find.widgetWithText(AppBar, 'Login'), findsOneWidget);
    expect(find.textContaining('Registrasi berhasil'), findsOneWidget);

    // Perform login
    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'tester@example.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    // Dashboard should show greeting with username from fake
    expect(find.textContaining('Halo'), findsOneWidget);
    expect(find.textContaining('Test User'), findsOneWidget);

    // Open profile via AppBar icon
    await tester.tap(find.byIcon(Icons.person).first);
    await tester.pumpAndSettle();
    expect(find.textContaining('Nama Lengkap'), findsOneWidget);

    // Logout
    await tester.tap(find.text('Keluar Aplikasi'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Login'), findsOneWidget);

    // Test reset password flow
    await tester.tap(find.text('Lupa Password?'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Reset Password'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'tester@example.com');
    await tester.tap(find.text('Kirim Link Reset'));
    await tester.pumpAndSettle();
    // After successful reset, UI navigates back to Login
    expect(find.widgetWithText(AppBar, 'Login'), findsOneWidget);
  });
}

// (no extra fakes needed)
