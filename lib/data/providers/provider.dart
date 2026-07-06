import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:projectmobile/core/providers/supabase_provider.dart';
import 'package:projectmobile/core/providers/auth_provider.dart';
import 'package:projectmobile/data/repositories/auth_repository.dart';
import 'package:projectmobile/data/models/profile_model.dart';
import 'package:projectmobile/data/repositories/notification_repository.dart';
import 'package:projectmobile/data/repositories/ticket_repository.dart';
import 'package:projectmobile/data/repositories/history_repository.dart';
import 'package:projectmobile/data/repositories/user_repository.dart';
import 'package:projectmobile/data/models/comment_model.dart';
import 'package:projectmobile/data/models/notification_model.dart';
import 'package:projectmobile/data/models/ticket_attachment_model.dart';
import 'package:projectmobile/data/models/ticket_history_model.dart';

// ============================================================
// 1. Repository Providers
// ============================================================

final authRepoProvider = Provider((ref) {
  return AuthRepository(ref.watch(supabaseProvider));
});

final ticketRepoProvider = Provider((ref) {
  return TicketRepository(ref.watch(supabaseProvider));
});

final notificationRepoProvider = Provider((ref) {
  return NotificationRepository(ref.watch(supabaseProvider));
});

final historyRepoProvider = Provider((ref) {
  return HistoryRepository(ref.watch(supabaseProvider));
});

final userRepoProvider = Provider((ref) {
  return UserRepository(ref.watch(supabaseProvider));
});

// ============================================================
// 2. Ticket Providers
// ============================================================

/// FR-005/006/007: List tiket sesuai role (role-filtered di repository)
final ticketsStreamProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final repo = ref.watch(ticketRepoProvider);
  final auth = ref.watch(authNotifierProvider);

  final role = auth.role.toLowerCase();
  final user = auth.user;
  
  // Admin: lihat semua tiket
  if (role == 'admin') {
    return await repo.getTickets();
  }
  
  // Helpdesk: hanya lihat tiket yang di-assign ke mereka
  if (role == 'helpdesk' && user != null) {
    return await repo.getTicketsAssignedToHelpdesk(user.id);
  }

  // User: hanya lihat tiket milik sendiri
  if (user == null) return <dynamic>[];
  return await repo.getTicketsForUser(user.id);
});

/// Attachments per tiket (dari tabel ticket_attachments)
final attachmentsProvider = FutureProvider.autoDispose.family<List<TicketAttachmentModel>, String>((ref, ticketId) {
  final repo = ref.watch(ticketRepoProvider);
  return repo.getAttachments(ticketId);
});

/// FR-010/011 / BR-005: History perubahan tiket per ticketId
final ticketHistoryProvider = FutureProvider.autoDispose.family<List<TicketHistoryModel>, String>((ref, ticketId) {
  final repo = ref.watch(historyRepoProvider);
  return repo.getTicketHistory(ticketId);
});

// ============================================================
// 3. Notification Providers
// ============================================================

/// FR-008: List notifikasi (FutureProvider)
final notificationsProvider = FutureProvider((ref) {
  final repo = ref.watch(notificationRepoProvider);
  return repo.getNotifications();
});

/// Realtime notifications for current user (StreamProvider)
final notificationsStreamProvider = StreamProvider.autoDispose<List<NotificationModel>>((ref) {
  final repo = ref.watch(notificationRepoProvider);
  final auth = ref.watch(authNotifierProvider);
  final user = auth.user;
  if (user == null) return const Stream.empty();
  return repo.getNotificationsStream(user.id);
});

// ============================================================
// 4. Comment Providers
// ============================================================

/// Stream komentar per tiket (realtime)
final commentsProvider = StreamProvider.autoDispose.family<List<CommentModel>, String>((ref, ticketId) {
  final repo = ref.watch(ticketRepoProvider);
  return repo.getCommentsStream(ticketId);
});

// ============================================================
// 5. Profile & User Providers
// ============================================================

/// Profil user by ID (untuk tampilan nama di komentar & tracking)
final profileProvider = FutureProvider.family<ProfileModel?, String>((ref, id) {
  final repo = ref.watch(authRepoProvider);
  return repo.getProfileById(id);
});

/// Daftar helpdesk (untuk dropdown assign ticket)
final helpdeskUsersProvider = FutureProvider.autoDispose<List<ProfileModel>>((ref) {
  final repo = ref.watch(authRepoProvider);
  return repo.getHelpdeskUsers();
});

/// Daftar admin (untuk notifikasi tiket baru dan komentar)
final adminUsersProvider = FutureProvider.autoDispose<List<ProfileModel>>((ref) {
  final repo = ref.watch(authRepoProvider);
  return repo.getAdminUsers();
});

/// FR-007: Admin — daftar SEMUA pengguna (untuk user management screen)
final userListProvider = FutureProvider.autoDispose<List<ProfileModel>>((ref) {
  final repo = ref.watch(userRepoProvider);
  return repo.getAllUsers();
});

/// Dropdown pelapor: hanya user aktif dengan role 'User' (untuk Helpdesk/Admin create ticket)
final userListForDropdownProvider = FutureProvider.autoDispose<List<ProfileModel>>((ref) {
  final repo = ref.watch(userRepoProvider);
  return repo.getUsersWithRoleUser();
});