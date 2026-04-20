import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider ini menyediakan instance SupabaseClient yang sudah diinisialisasi di main.dart.
/// Semua repository (Auth, Ticket, Notification) akan bergantung pada provider ini.
final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});