import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';

class UserRepository {
  final SupabaseClient _supabase;
  UserRepository(this._supabase);

  /// FR-007: Admin — ambil semua pengguna terdaftar (semua role)
  Future<List<ProfileModel>> getAllUsers() async {
    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .order('full_name', ascending: true);

      return (data as List)
          .map((json) => ProfileModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } catch (e) {
      debugPrint('Error fetching all users: $e');
      rethrow;
    }
  }

  /// FR-007: Admin — ambil hanya user dengan role 'User' (untuk dropdown pelapor)
  Future<List<ProfileModel>> getUsersWithRoleUser() async {
    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('role', 'User')
          .eq('is_active', true)
          .order('full_name', ascending: true);

      return (data as List)
          .map((json) => ProfileModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } catch (e) {
      debugPrint('Error fetching user list: $e');
      rethrow;
    }
  }

  /// FR-007: Admin — ubah role pengguna
  Future<void> updateUserRole(String userId, String role) async {
    try {
      await _supabase
          .from('profiles')
          .update({'role': role})
          .eq('id', userId);
    } catch (e) {
      debugPrint('Error updating user role: $e');
      rethrow;
    }
  }

  /// FR-007 / BR-002: Admin — toggle is_active pengguna
  Future<void> setUserActive(String userId, bool isActive) async {
    try {
      await _supabase
          .from('profiles')
          .update({'is_active': isActive})
          .eq('id', userId);
    } catch (e) {
      debugPrint('Error updating user active status: $e');
      rethrow;
    }
  }
}
