import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ticket_history_model.dart';

class HistoryRepository {
  final SupabaseClient _supabase;
  HistoryRepository(this._supabase);

  /// FR-010 / FR-011 / BR-005: Ambil semua history perubahan tiket berdasarkan ticket_id.
  /// Data dibaca dari tabel ticket_history yang diisi otomatis oleh Postgres trigger.
  /// Urutan: terlama → terbaru (ascending by created_at).
  Future<List<TicketHistoryModel>> getTicketHistory(String ticketId) async {
    try {
      final response = await _supabase
          .from('ticket_history')
          .select()
          .eq('ticket_id', ticketId)
          .order('created_at', ascending: true);

      return (response as List)
          .map((json) => TicketHistoryModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } catch (e) {
      debugPrint('Error fetching ticket history: $e');
      rethrow;
    }
  }
}
