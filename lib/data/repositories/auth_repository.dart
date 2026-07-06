import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
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
  Future<void> updateProfile(String fullName, {String? phoneNumber});
  Future<String?> uploadAvatar(File avatar);
  Future<void> saveFcmToken(String token);
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

  // Mengambil data profil (Role, Full Name, isActive, dll.) untuk session saat ini
  @override
  Future<ProfileModel?> getMyProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;
    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (data == null) {
        return null;
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

  // Profile Edit: Update nama dan nomor telepon di tabel profiles
  @override
  Future<void> updateProfile(String fullName, {String? phoneNumber}) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    try {
      final updates = <String, dynamic>{'full_name': fullName};
      if (phoneNumber != null) updates['phone_number'] = phoneNumber;
      await _supabase.from('profiles').update(updates).eq('id', user.id);
    } catch (e) {
      debugPrint('Error updating profile: $e');
      rethrow;
    }
  }

  // Profile Edit: Upload avatar ke Supabase Storage bucket 'avatars', return public URL
  @override
  Future<String?> uploadAvatar(File avatar) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;
    try {
      final ext = p.extension(avatar.path).isNotEmpty ? p.extension(avatar.path) : '.jpg';
      final path = '${user.id}/avatar$ext';
      const bucket = 'avatars';
      final bytes = await avatar.readAsBytes();
      // upsert: overwrite existing avatar
      await _supabase.storage.from(bucket).uploadBinary(
        path,
        bytes,
        fileOptions: const FileOptions(upsert: true),
      );
      final url = _supabase.storage.from(bucket).getPublicUrl(path);
      // Simpan URL ke tabel profiles
      await _supabase.from('profiles').update({'avatar_url': url}).eq('id', user.id);
      return url;
    } catch (e) {
      debugPrint('Error uploading avatar: $e');
      rethrow;
    }
  }

  // Simpan FCM token ke kolom fcm_token di tabel profiles
  @override
  Future<void> saveFcmToken(String token) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    try {
      await _supabase
          .from('profiles')
          .update({'fcm_token': token})
          .eq('id', user.id);
    } catch (e) {
      debugPrint('Error saving FCM token: $e');
    }
  }
}