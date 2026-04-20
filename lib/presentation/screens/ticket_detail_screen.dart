import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:projectmobile/core/providers/auth_provider.dart';
import 'package:projectmobile/data/models/ticket_model.dart';
import 'package:projectmobile/data/providers/provider.dart';
import 'package:projectmobile/core/utils/date_formatter.dart';
import 'package:projectmobile/core/notification/notification_banner.dart';

class TicketDetailScreen extends ConsumerStatefulWidget {
  final String id;
  const TicketDetailScreen({super.key, required this.id});

  @override
  ConsumerState<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends ConsumerState<TicketDetailScreen> {
  TicketModel? _ticket;
  bool _loading = true;
  final _commentCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final repo = ref.read(ticketRepoProvider);
      _ticket = await repo.getTicketById(widget.id);
    } catch (e, st) {
        debugPrint('Supabase error in getTicketById: $e');
        debugPrint(st.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _addComment() async {
    final text = _commentCtl.text.trim();
    if (text.isEmpty) return;
    final repo = ref.read(ticketRepoProvider);
    try {
      await repo.addComment(widget.id, text);
      _commentCtl.clear();
      await _load();
    } catch (e, st) {
      debugPrint('Supabase error in addComment: $e');
      debugPrint(st.toString());
    }
  }

  Future<void> _assign(String assignee) async {
    setState(() => _loading = true);
    final repo = ref.read(ticketRepoProvider);
    try {
      await repo.assignTicket(widget.id, assignee);
      ref.invalidate(ticketsStreamProvider); // Refresh list
      // Show local notification banner for immediate feedback
      ref.read(notificationStateProvider.notifier).state = NotificationData('Tiket ditugaskan', 'Tiket telah ditugaskan ke $assignee', ticketId: widget.id);
      await _load();
    } catch (e, st) {
        debugPrint('Supabase error in assignTicket: $e');
        debugPrint(st.toString());
      setState(() => _loading = false);
    }
  }

  Future<void> _changeStatus(String status) async {
    setState(() => _loading = true);
    final repo = ref.read(ticketRepoProvider);
    try {
      await repo.updateTicketStatus(widget.id, status);
      ref.invalidate(ticketsStreamProvider); // Refresh list
      // Show local notification banner for immediate feedback
      ref.read(notificationStateProvider.notifier).state = NotificationData('Status tiket diperbarui', 'Status diubah menjadi $status', ticketId: widget.id);
      await _load(); // Reload detail
    } catch (e, st) {
      debugPrint('Supabase error in updateTicketStatus: $e');
      debugPrint(st.toString());
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _commentCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final role = authState.role.toLowerCase();
    final helpdeskListAsync = role == 'admin' ? ref.watch(helpdeskUsersProvider) : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Tiket'),
        actions: role == 'admin' || role == 'helpdesk'
            ? [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) async {
                    if (_ticket == null) return;
                    if (value == 'change_status') {
                      String statusVal = _ticket!.status;
                      await showDialog(
                        context: context,
                        builder: (ctx) {
                          return AlertDialog(
                            title: const Text('Change Status'),
                            content: StatefulBuilder(builder: (ctx, setSt) {
                              return DropdownButton<String>(
                                value: statusVal,
                                items: ['Open', 'In Progress', 'Resolved', 'Closed']
                                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                    .toList(),
                                onChanged: (v) {
                                  if (v == null) return;
                                  setSt(() => statusVal = v);
                                },
                              );
                            }),
                            actions: [
                              TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
                              TextButton(
                                onPressed: () async {
                                  Navigator.of(ctx).pop();
                                  await _changeStatus(statusVal);
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    } else if (value == 'assign' && role == 'admin') {
                      // Assign dialog dengan dropdown helpdesk
                      if (helpdeskListAsync == null) return;
                      
                      helpdeskListAsync.when(
                        data: (helpdeskList) async {
                          String? selectedHelpdeskId = _ticket!.assignedTo;
                          final availableHelpdesk = helpdeskList;

                          if (availableHelpdesk.isEmpty) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Tidak ada Helpdesk tersedia')),
                              );
                            }
                            return;
                          }

                          if (context.mounted) {
                            await showDialog(
                              context: context,
                              builder: (ctx) {
                                return StatefulBuilder(
                                  builder: (ctx, setSt) {
                                    return AlertDialog(
                                      title: const Text('Assign Ticket ke Helpdesk'),
                                      content: SizedBox(
                                        width: double.maxFinite,
                                        height: 300,
                                        child: Scrollbar(
                                          thumbVisibility: true,
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: availableHelpdesk.length,
                                            itemBuilder: (c, i) {
                                              final hd = availableHelpdesk[i];
                                              return RadioListTile<String>(
                                                value: hd.id,
                                                groupValue: selectedHelpdeskId,
                                                title: Text(hd.fullName ?? hd.id),
                                                subtitle: Text(hd.id, style: const TextStyle(fontSize: 11)),
                                                onChanged: (v) {
                                                  setSt(() => selectedHelpdeskId = v);
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
                                        TextButton(
                                          onPressed: () async {
                                            if (selectedHelpdeskId == null || selectedHelpdeskId!.isEmpty) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Pilih Helpdesk terlebih dahulu')),
                                                );
                                              }
                                              return;
                                            }
                                            Navigator.of(ctx).pop();
                                            await _assign(selectedHelpdeskId!);
                                          },
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            );
                          }
                        },
                        loading: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => const AlertDialog(
                              content: CircularProgressIndicator(),
                            ),
                          );
                        },
                        error: (err, stack) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error memuat Helpdesk: $err')),
                          );
                        },
                      );
                    }
                  },
                  itemBuilder: (ctx) {
                    final items = <PopupMenuEntry<String>>[
                      const PopupMenuItem(value: 'change_status', child: Text('Ubah Status')),
                    ];
                    // Hanya admin yang bisa assign
                    if (role == 'admin') {
                      items.add(const PopupMenuItem(value: 'assign', child: Text('Assign ke Helpdesk')));
                    }
                    return items;
                  },
                )
              ]
            : null,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _ticket == null
              ? const Center(child: Text('Ticket not found'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_ticket!.title, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text('Status: ${_ticket!.status}'),
                      if (_ticket!.assignedTo != null) Text('Assignee: ${_ticket!.assignedTo}'),
                      const SizedBox(height: 12),
                      const SizedBox.shrink(),
                      Text(_ticket!.description ?? ''),
                      const SizedBox(height: 12),
                      if (_ticket!.imageUrl != null) ...[
                        const Text('Attachments:'),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {
                            // open full screen image
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => Scaffold(
                              appBar: AppBar(),
                              body: Center(child: Image.network(_ticket!.imageUrl!)),
                            )));
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(_ticket!.imageUrl!, height: 200, width: double.infinity, fit: BoxFit.cover),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      const Text('Comments', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      // Comments are loaded via provider to reflect DB state in realtime
                      Builder(builder: (ctx) {
                        final commentsAsync = ref.watch(commentsProvider(widget.id));
                        return commentsAsync.when(
                          data: (comments) {
                            return Expanded(
                              child: ListView.builder(
                                itemCount: comments.length,
                                itemBuilder: (ctx, idx) {
                                  final c = comments[idx];
                                  // Show author name and align chat bubble: compare comment userId with current user
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
                                    child: Builder(builder: (ctx) {
                                      final authState = ref.watch(authNotifierProvider);
                                      final myUserId = authState.user?.id;
                                      final isMe = myUserId != null && myUserId == c.userId;
                                      final profileAsync = ref.watch(profileProvider(c.userId ?? ''));

                                      return profileAsync.when(
                                        data: (profile) {
                                          final name = profile?.fullName ?? (isMe ? 'You' : 'User');
                                          return Column(
                                            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                            children: [
                                              Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                              const SizedBox(height: 4),
                                              Align(
                                                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                                                child: Container(
                                                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                                  decoration: BoxDecoration(
                                                    color: isMe ? Theme.of(context).colorScheme.primary : Colors.grey.shade200,
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(c.message, style: TextStyle(color: isMe ? Theme.of(context).colorScheme.onPrimary : Colors.black87)),
                                                      const SizedBox(height: 6),
                                                      Text(
                                                        DateFormatter.formatShort(c.createdAt),
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          color: isMe
                                                              ? Theme.of(context).colorScheme.onPrimary.withAlpha((0.85 * 255).round())
                                                              : Colors.grey[600],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                        loading: () => const SizedBox.shrink(),
                                        error: (_, _) {
                                          final name = isMe ? 'You' : 'User';
                                          return Column(
                                            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                            children: [
                                              Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                              const SizedBox(height: 4),
                                              Align(
                                                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                                                child: Container(
                                                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                                  decoration: BoxDecoration(
                                                    color: isMe ? Theme.of(context).colorScheme.primary : Colors.grey.shade200,
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(c.message, style: TextStyle(color: isMe ? Theme.of(context).colorScheme.onPrimary : Colors.black87)),
                                                      const SizedBox(height: 6),
                                                      Text(DateFormatter.formatShort(c.createdAt), style: TextStyle(fontSize: 10, color: isMe ? Theme.of(context).colorScheme.onPrimary.withAlpha((0.85 * 255).round()) : Colors.grey[600])),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }),
                                  );
                                },
                              ),
                            );
                          },
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (e, st) => Center(child: Text('Error loading comments')),
                        );
                      }),
                      Row(
                        children: [
                          Expanded(child: TextField(controller: _commentCtl, decoration: const InputDecoration(hintText: 'Write a comment'))),
                          IconButton(onPressed: _addComment, icon: const Icon(Icons.send)),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }
}
