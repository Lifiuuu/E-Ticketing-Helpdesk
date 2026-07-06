import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:projectmobile/data/models/ticket_history_model.dart';
import 'package:projectmobile/data/providers/provider.dart';
import 'package:projectmobile/core/utils/date_formatter.dart';

class TrackingTicketScreen extends ConsumerWidget {
  final String ticketId;
  const TrackingTicketScreen({super.key, required this.ticketId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(ticketHistoryProvider(ticketId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Perubahan'),
      ),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.history_toggle_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Riwayat belum tersedia',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pastikan tabel ticket_history dan trigger on_ticket_update '
                  'sudah dibuat di Supabase.\n\nDetail: $e',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
        data: (historyList) {
          if (historyList.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.timeline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Belum ada riwayat perubahan',
                      style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: historyList.length,
            itemBuilder: (context, index) {
              final entry = historyList[index];
              final isLast = index == historyList.length - 1;
              return _TimelineEntry(entry: entry, isLast: isLast, ref: ref);
            },
          );
        },
      ),
    );
  }
}

class _TimelineEntry extends StatelessWidget {
  final TicketHistoryModel entry;
  final bool isLast;
  final WidgetRef ref;

  const _TimelineEntry({required this.entry, required this.isLast, required this.ref});

  IconData get _fieldIcon {
    switch (entry.fieldChanged) {
      case 'status': return Icons.label_outline;
      case 'assigned_to': return Icons.person_outline;
      default: return Icons.edit_outlined;
    }
  }

  Color get _fieldColor {
    switch (entry.fieldChanged) {
      case 'status': return Colors.blue;
      case 'assigned_to': return Colors.orange;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          SizedBox(
            width: 48,
            child: Column(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _fieldColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: _fieldColor, width: 2),
                  ),
                  child: Icon(_fieldIcon, size: 18, color: _fieldColor),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: Colors.grey.shade300,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Field label
                      Text(
                        entry.fieldLabel,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _fieldColor,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Old value → New value
                      Row(
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: _ValueDisplay(
                                value: entry.oldValue,
                                isAssignedTo: entry.fieldChanged == 'assigned_to',
                                color: Colors.red,
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            child: Icon(Icons.arrow_forward, size: 14, color: Colors.grey),
                          ),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: _ValueDisplay(
                                value: entry.newValue,
                                isAssignedTo: entry.fieldChanged == 'assigned_to',
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Diubah oleh + waktu
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            DateFormatter.formatShort(entry.createdAt),
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                          if (entry.changedBy != null) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.person_outline, size: 12, color: Colors.grey),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Consumer(
                                builder: (ctx, consumerRef, _) {
                                  final profileAsync = consumerRef.watch(profileProvider(entry.changedBy!));
                                  return profileAsync.when(
                                    data: (p) => Text(
                                      p?.fullName ?? 'Unknown',
                                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    loading: () => const Text('...', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                    error: (_, __) => const Text('—', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                  );
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ValueDisplay extends ConsumerWidget {
  final String? value;
  final bool isAssignedTo;
  final Color color;

  const _ValueDisplay({
    required this.value,
    required this.isAssignedTo,
    required this.color,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (value == null || value == 'null' || value!.isEmpty) {
      return Text('—', style: TextStyle(fontSize: 12, color: color));
    }

    if (!isAssignedTo) {
      return Text(value!, style: TextStyle(fontSize: 12, color: color));
    }

    // Jika isAssignedTo, value adalah UUID dari profile (atau string null)
    final profileAsync = ref.watch(profileProvider(value!));
    return profileAsync.when(
      data: (p) => Text(
        p?.fullName ?? value!,
        style: TextStyle(fontSize: 12, color: color),
        overflow: TextOverflow.ellipsis,
      ),
      loading: () => Text('...', style: TextStyle(fontSize: 12, color: color)),
      error: (_, __) => Text(value!, style: TextStyle(fontSize: 12, color: color), overflow: TextOverflow.ellipsis),
    );
  }
}
