import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// import 'package:projectmobile/data/models/notification_model.dart';
import 'package:projectmobile/data/providers/provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                    if (!n.isRead)
                      IconButton(
                        icon: const Icon(Icons.mark_email_read),
                        onPressed: () {
                          // Mark as read (fire-and-forget) to avoid blocking UI/navigation
                          ref.read(notificationRepoProvider).markAsRead(n.id);
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        await ref.read(notificationRepoProvider).deleteNotification(n.id);
                      },
                    ),
                  ],
                ),
                onTap: () async {
                  // Mark as read when user opens the notification, then navigate
                  final router = GoRouter.of(context);
                  // Fire-and-forget marking so navigation isn't blocked by network latency
                  ref.read(notificationRepoProvider).markAsRead(n.id);
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
