import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'notification_service.dart';
import 'package:go_router/go_router.dart';

class NotificationBanner extends StatelessWidget {
  const NotificationBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationService>(builder: (context, svc, child) {
      final entry = svc.current;
      if (entry == null) return const SizedBox.shrink();
      return Positioned(
        top: 16,
        left: 16,
        right: 16,
        child: Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).colorScheme.primary,
          child: InkWell(
            onTap: () {
              svc.clear();
              // navigate to ticket detail
              GoRouter.of(context).go('/ticket/${entry.ticketId}');
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.notifications, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(entry.message, style: const TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
