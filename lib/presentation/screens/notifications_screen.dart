import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// import 'package:projectmobile/data/models/notification_model.dart';
import 'package:projectmobile/data/providers/provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // Otomatis tandai semua notifikasi sebagai telah dibaca saat halaman ini dibuka
    Future.microtask(() async {
      await ref.read(notificationRepoProvider).markAllAsRead();
      // Paksa refresh stream agar badge merah di dashboard langsung hilang
      ref.invalidate(notificationsStreamProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifsAsync = ref.watch(notificationsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: notifsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (list) {
          if (list.isEmpty) return const Center(child: Text('No notifications'));
          return ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, idx) {
              final n = list[idx];
              return ListTile(
                title: Text(n.title),
                subtitle: Text(n.message),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(n.timeAgo()),
                    const SizedBox(width: 8),
                    // Tombol tandai sudah dibaca dihapus karena sekarang otomatis terbaca
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        await ref.read(notificationRepoProvider).deleteNotification(n.id);
                      },
                    ),
                  ],
                ),
                onTap: () async {
                  // Navigate to ticket detail
                  final router = GoRouter.of(context);
                  if (n.ticketId != null && n.ticketId!.isNotEmpty) {
                    router.push('/ticket/${Uri.encodeComponent(n.ticketId!)}');
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
