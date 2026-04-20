import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/notification_model.dart';
import '../../data/providers/provider.dart';

// Keep track of notification ids we've already shown in the banner
final _shownNotificationIdsProvider = StateProvider<Set<String>>((ref) => <String>{});

// State provider sederhana untuk memicu banner
final notificationStateProvider = StateProvider<NotificationData?>((ref) => null);

// Timer provider to auto-dismiss banner after a short delay
final _bannerTimerProvider = StateProvider<Timer?>((ref) => null);

class NotificationData {
  final String title;
  final String message;
  final String? id;
  final String? ticketId; // optional, used to navigate to ticket detail
  NotificationData(this.title, this.message, {this.ticketId, this.id});
}

class NotificationBanner extends ConsumerWidget {
  const NotificationBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to realtime notifications stream and show a banner for the first
    // unseen notification that hasn't been shown yet in this session.
    ref.listen<AsyncValue<List<NotificationModel>>>(notificationsStreamProvider, (prev, next) {
      next.whenData((list) {
        final shown = ref.read(_shownNotificationIdsProvider);
        for (final n in list) {
          if (!shown.contains(n.id) && !n.isRead) {
            // show it and record as shown
            ref.read(notificationStateProvider.notifier).state = NotificationData(n.title, n.message, ticketId: n.ticketId);
            ref.read(_shownNotificationIdsProvider.notifier).state = {...shown, n.id};
            break;
          }
        }
      });
    });

    // Auto-dismiss: when notificationStateProvider becomes non-null, start a
    // 3-second timer to clear the banner. Cancel any existing timer first.
    ref.listen<NotificationData?>(notificationStateProvider, (prev, next) {
      final oldTimer = ref.read(_bannerTimerProvider);
      if (oldTimer != null) {
        oldTimer.cancel();
      }

      if (next != null) {
        final timer = Timer(const Duration(seconds: 3), () {
          ref.read(notificationStateProvider.notifier).state = null;
          ref.read(_bannerTimerProvider.notifier).state = null;
        });
        ref.read(_bannerTimerProvider.notifier).state = timer;
      } else {
        ref.read(_bannerTimerProvider.notifier).state = null;
      }
    });

    final notification = ref.watch(notificationStateProvider);

    if (notification == null) return const SizedBox.shrink();

    return Positioned(
      top: 50,
      left: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blueAccent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black26)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(notification.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text(notification.message, style: const TextStyle(color: Colors.white)),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                      if (notification.ticketId != null)
                        TextButton(
                          onPressed: () async {
                            final router = GoRouter.of(context);
                            // Mark as read, navigate to ticket detail and clear notification
                            if (notification.id != null) {
                              await ref.read(notificationRepoProvider).markAsRead(notification.id!);
                            }
                            ref.read(notificationStateProvider.notifier).state = null;
                            router.push('/ticket/${notification.ticketId}');
                          },
                          child: const Text('Buka', style: TextStyle(color: Colors.white)),
                        ),
                  TextButton(
                    onPressed: () => ref.read(notificationStateProvider.notifier).state = null,
                    child: const Text('Tutup', style: TextStyle(color: Colors.white70)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}