import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:projectmobile/data/repositories/auth_repository.dart';
import 'package:projectmobile/core/providers/supabase_provider.dart';

// 1. STATE CLASS: Menampung data auth yang sedang aktif
class AuthState {
  final User? user;
  final String? username;
  final String role; // 'User', 'Admin', atau 'Helpdesk'
  final bool isLoading;
  final String? error;

  AuthState({
    this.user,
    this.username,
    this.role = 'User',
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    String? username,
    String? role,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      username: username ?? this.username,
      role: role ?? this.role,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// 2. NOTIFIER: Logika untuk mengubah state
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepoInterface _repo;
  final SupabaseClient? _supabase;

  AuthNotifier(this._repo, this._supabase, {bool skipInit = false}) : super(AuthState()) {
    if (!skipInit) {
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
        
        // --- TAMBAHKAN PENGECEKAN INI ---
        // Jika setelah direfresh user masih null (karena profil tidak ada di DB)
        if (state.user == null) {
          return false; // Laporkan ke UI bahwa login GAGAL secara sistem
        }
        return true; // Benar-benar sukses
        
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
  return AuthNotifier(repo, supabase);
});