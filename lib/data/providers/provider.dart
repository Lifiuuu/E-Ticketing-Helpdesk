import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:projectmobile/core/providers/supabase_provider.dart';
import 'package:projectmobile/core/providers/auth_provider.dart';
import 'package:projectmobile/data/repositories/auth_repository.dart';
import 'package:projectmobile/data/models/profile_model.dart';
import 'package:projectmobile/data/repositories/notification_repository.dart';
import 'package:projectmobile/data/repositories/ticket_repository.dart';
import 'package:projectmobile/data/models/comment_model.dart';
import 'package:projectmobile/data/models/notification_model.dart';

// 1. Provider untuk Repository (Mesin Database)
final authRepoProvider = Provider((ref) {
  return AuthRepository(ref.watch(supabaseProvider));
});

final ticketRepoProvider = Provider((ref) {
  return TicketRepository(ref.watch(supabaseProvider));
});

final notificationRepoProvider = Provider((ref) {
  return NotificationRepository(ref.watch(supabaseProvider));
});

// 2. FutureProvider untuk List Tiket (Otomatis Handle Loading/Error)
// Digunakan di TicketsListScreen untuk FR-010 [cite: 92-96]
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

// 3. Provider untuk Notifikasi (FR-007) [cite: 78-83]
final notificationsProvider = FutureProvider((ref) {
  final repo = ref.watch(notificationRepoProvider);
  return repo.getNotifications();
});

// Realtime notifications for current user
final notificationsStreamProvider = StreamProvider.autoDispose<List<NotificationModel>>((ref) {
  final repo = ref.watch(notificationRepoProvider);
  final auth = ref.watch(authNotifierProvider);
  final user = auth.user;
  if (user == null) return const Stream.empty();
  return repo.getNotificationsStream(user.id);
});

// Comments provider per ticket
// Stream provider for comments so UI updates in realtime when DB changes
final commentsProvider = StreamProvider.autoDispose.family<List<CommentModel>, String>((ref, ticketId) {
  final repo = ref.watch(ticketRepoProvider);
  return repo.getCommentsStream(ticketId);
});

// Profile provider by id
final profileProvider = FutureProvider.family<ProfileModel?, String>((ref, id) {
  final repo = ref.watch(authRepoProvider);
  return repo.getProfileById(id);
});

// Helpdesk users provider (untuk dropdown assign ticket)
final helpdeskUsersProvider = FutureProvider.autoDispose<List<ProfileModel>>((ref) {
  final repo = ref.watch(authRepoProvider);
  return repo.getHelpdeskUsers();
});

// Admin users provider (untuk notify admin pada tiket baru dan komentar)
final adminUsersProvider = FutureProvider.autoDispose<List<ProfileModel>>((ref) {
  final repo = ref.watch(authRepoProvider);
  return repo.getAdminUsers();
});