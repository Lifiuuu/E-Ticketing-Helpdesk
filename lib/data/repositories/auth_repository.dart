import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';

/// Abstraction for Auth repository to allow test doubles in tests.
abstract class AuthRepoInterface {
  Future<AuthResponse> signIn(String email, String password);
  Future<AuthResponse> signUp(String email, String password, String fullName);
  Future<void> signOut();
  Future<ProfileModel?> getMyProfile();
  Future<ProfileModel?> getProfileById(String id);
  Future<List<ProfileModel>> getHelpdeskUsers();
  Future<List<ProfileModel>> getAdminUsers();
}

class AuthRepository implements AuthRepoInterface {
  final SupabaseClient _supabase;
  AuthRepository(this._supabase);

  // FR-001: Login
  @override
  Future<AuthResponse> signIn(String email, String password) async {
    try {
      return await _supabase.auth.signInWithPassword(email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

  // FR-003: Register 
  @override
  Future<AuthResponse> signUp(String email, String password, String fullName) async {
    try {
      return await _supabase.auth.signUp(
        email: email,
        password: password,
        // Metadata ini yang akan diambil oleh trigger di Supabase-mu
        data: {'full_name': fullName}, 
      );
    } catch (e) {
      rethrow;
    }
  }

  // FR-002: Logout
  @override
  Future<void> signOut() async {
    try {
      return await _supabase.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Mengambil data profil (Role & Full Name) untuk session saat ini
  @override
  Future<ProfileModel?> getMyProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;
    try {
      // 1. UBAH .single() MENJADI .maybeSingle()
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      // 2. CEK JIKA DATA KOSONG (0 rows)
      if (data == null) {
        return null; // Kembalikan null dengan tenang tanpa melempar error
      }

      return ProfileModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  // Ambil profil berdasarkan id (dipakai untuk menampilkan nama pada komentar)
  @override
  Future<ProfileModel?> getProfileById(String id) async {
    try {
      final data = await _supabase.from('profiles').select().eq('id', id).maybeSingle();
      if (data == null) return null;
      return ProfileModel.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      rethrow;
    }
  }

  // Ambil semua user dengan role Helpdesk (untuk dropdown assign di ticket detail)
  @override
  Future<List<ProfileModel>> getHelpdeskUsers() async {
    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('role', 'Helpdesk')
          .order('full_name', ascending: true);
      
      return (data as List).map((json) => ProfileModel.fromJson(Map<String, dynamic>.from(json))).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Ambil semua user dengan role Admin (untuk notify admin pada tiket baru dan komentar)
  @override
  Future<List<ProfileModel>> getAdminUsers() async {
    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('role', 'Admin')
          .order('full_name', ascending: true);
      
      return (data as List).map((json) => ProfileModel.fromJson(Map<String, dynamic>.from(json))).toList();
    } catch (e) {
      rethrow;
    }
  }
}