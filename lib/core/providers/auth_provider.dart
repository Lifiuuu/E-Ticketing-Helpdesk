import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:projectmobile/data/repositories/auth_repository.dart';
import 'package:projectmobile/core/providers/supabase_provider.dart';
import 'package:projectmobile/core/notification/fcm_service.dart';

// 1. STATE CLASS: Menampung data auth yang sedang aktif
class AuthState {
  final User? user;
  final String? username;
  final String role; // 'User', 'Admin', atau 'Helpdesk'
  final bool isLoading;
  final String? error;
  final bool isActive;
  final String? phoneNumber;
  final String? avatarUrl;

  AuthState({
    this.user,
    this.username,
    this.role = 'User',
    this.isLoading = false,
    this.error,
    this.isActive = true,
    this.phoneNumber,
    this.avatarUrl,
  });

  AuthState copyWith({
    User? user,
    String? username,
    String? role,
    bool? isLoading,
    String? error,
    bool? isActive,
    String? phoneNumber,
    String? avatarUrl,
  }) {
    return AuthState(
      user: user ?? this.user,
      username: username ?? this.username,
      role: role ?? this.role,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isActive: isActive ?? this.isActive,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}

// 2. NOTIFIER: Logika untuk mengubah state
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepoInterface _repo;
  final SupabaseClient? _supabase;
  FcmService? _fcmService;
  final Ref? ref;

  AuthNotifier(this._repo, this._supabase, {this.ref, bool skipInit = false}) : super(AuthState()) {
    if (!skipInit) {
      _fcmService = FcmService(_supabase!, ref: ref);
      // WAJIB panggil initialize() agar background/foreground listener aktif!
      _fcmService?.initialize();
      _init();
    }
  }

  // Inisialisasi: Cek apakah user sudah login sebelumnya
  void _init() {
    final session = _supabase?.auth.currentSession;
    if (session != null) {
      _refreshProfile(session.user);
    }

    // Pantau perubahan status auth secara realtime
    _supabase?.auth.onAuthStateChange.listen((data) {
      debugPrint('=== onAuthStateChange event: ${data.event}');
      debugPrint('onAuthStateChange data: $data');
      debugPrint('currentSession at event: ${data.session}');
      final event = data.event;
      final user = data.session?.user;

      // TANGKAP SINYAL RESET PASSWORD
      if (event == AuthChangeEvent.passwordRecovery) {
        // Kita ubah state agar router tahu kita harus ke halaman Update Password
        debugPrint('=== PASSWORD RECOVERY event received ===');
        state = state.copyWith(isLoading: false);
      }

      if (user != null) {
        _refreshProfile(user);
      } else {
        state = AuthState(); // Reset jika logout
      }
    });
  }

  // Fungsi internal untuk ambil data dari tabel public.profiles
  Future<void> _refreshProfile(User user) async {
    final profile = await _repo.getMyProfile();
    if (profile != null) {
      state = state.copyWith(
        user: user,
        username: profile.fullName,
        role: profile.role,
        isActive: profile.isActive,
        phoneNumber: profile.phoneNumber,
        avatarUrl: profile.avatarUrl,
        isLoading: false,
        error: null,
      );
    } else {
      // If there is no profile row for this user, surface a clear error
      state = state.copyWith(
        user: null,
        username: null,
        role: 'User',
        isLoading: false,
        error: 'Profil tidak ditemukan untuk user id: ${user.id}',
      );
    }
  }

  // FR-001: Login
  Future<bool> login(String email, String password) async {
    // Reset error di awal
    state = state.copyWith(isLoading: true, error: null); 
    try {
      await _repo.signIn(email, password);
      
      User? user = _supabase?.auth.currentUser;
      int tries = 0;
      while (user == null && tries < 5) {
        await Future.delayed(const Duration(milliseconds: 200));
        user = _supabase?.auth.currentUser;
        tries++;
      }
      
      if (user != null) {
        await _refreshProfile(user);
        
        if (state.user == null) {
          return false;
        }

        // Simpan FCM token setelah login berhasil
        await _fcmService?.refreshAndSaveToken();

        return true;
        
      } else {
        state = state.copyWith(isLoading: false, error: 'Login gagal: sesi tidak ditemukan');
        return false;
      }
    } catch (e) {
      // ---> TAMBAHAN UNTUK CEK LOG TERMINAL <---
      debugPrint('=== ERROR LOGIN SUPABASE: $e ===');
      
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  // FR-003: Register
  Future<bool> register(String username, String email, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repo.signUp(email, password, username);
      // After sign up we wait briefly for a session to appear and refresh profile
      User? user = _supabase?.auth.currentUser;
      int tries = 0;
      while (user == null && tries < 5) {
        await Future.delayed(const Duration(milliseconds: 200));
        user = _supabase?.auth.currentUser;
        tries++;
      }
      if (user != null) {
        await _refreshProfile(user);
      } else {
        state = state.copyWith(isLoading: false, error: null);
      }
      return true;
      } catch (e) {
      // log error for debugging (use debugPrint instead of print)
      debugPrint('=== ERROR REGISTER SUPABASE: $e ===');
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  // FR-004: Reset Password
  Future<bool> resetPassword(String email) async {
    try {
      final client = _supabase;
      if (client == null) return false;
      await client.auth.resetPasswordForEmail(
        email,
        // URL ini HARUS sama persis dengan yang kamu daftarkan di Supabase Dashboard
        redirectTo: 'eticketing://reset-callback/',
      );
      state = state.copyWith(error: null);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // FR-002: Logout
  void logout() {
    // Hapus FCM token dari Supabase saat logout
    _fcmService?.clearToken();
    _repo.signOut();
    state = AuthState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// 3. PROVIDER: Yang dipanggil di UI (ref.watch)
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final supabase = ref.watch(supabaseProvider);
  // Pastikan kamu sudah buat authRepoProvider di lib/data/providers.dart
  final repo = AuthRepository(supabase);
  return AuthNotifier(repo, supabase, ref: ref);
});