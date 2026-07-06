import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:projectmobile/core/providers/auth_provider.dart';
import 'package:projectmobile/data/models/ticket_model.dart';
import 'package:projectmobile/data/providers/provider.dart';
import 'package:projectmobile/core/utils/date_formatter.dart';
import 'package:projectmobile/presentation/widgets/attachment_grid.dart';

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
      ref.invalidate(ticketsStreamProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tiket telah ditugaskan ke helpdesk')),
        );
      }
      await _load();
    } catch (e, st) {
      debugPrint('Supabase error in assignTicket: $e');
      debugPrint(st.toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal assign: $e')),
        );
      }
      setState(() => _loading = false);
    }
  }

  Future<void> _changeStatus(String status) async {
    setState(() => _loading = true);
    final repo = ref.read(ticketRepoProvider);
    try {
      await repo.updateTicketStatus(widget.id, status);
      ref.invalidate(ticketsStreamProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status diubah menjadi $status')),
        );
      }
      await _load();
    } catch (e, st) {
      debugPrint('Supabase error in updateTicketStatus: $e');
      debugPrint(st.toString());
      setState(() => _loading = false);
    }
  }

  Future<void> _deleteTicket() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Tiket'),
        content: const Text('Apakah Anda yakin ingin menghapus tiket ini? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _loading = true);
      try {
        final repo = ref.read(ticketRepoProvider);
        await repo.deleteTicket(widget.id);
        ref.invalidate(ticketsStreamProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tiket berhasil dihapus')),
          );
          context.pop();
        }
      } catch (e, st) {
        debugPrint('Supabase error in deleteTicket: $e');
        debugPrint(st.toString());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
        setState(() => _loading = false);
      }
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
    final attachmentsAsync = ref.watch(attachmentsProvider(widget.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Tiket'),
        actions: [
          // Tombol Riwayat Perubahan (semua role)
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Riwayat Perubahan',
            onPressed: () => context.push('/ticket/${widget.id}/tracking'),
          ),
          // Menu admin/helpdesk: ubah status & assign
          if (role == 'admin' || role == 'helpdesk')
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
                        title: const Text('Ubah Status'),
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
                          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Batal')),
                          TextButton(
                            onPressed: () async {
                              Navigator.of(ctx).pop();
                              await _changeStatus(statusVal);
                            },
                            child: const Text('Simpan'),
                          ),
                        ],
                      );
                    },
                  );
                } else if (value == 'assign' && role == 'admin') {
                  if (helpdeskListAsync == null) return;
                  helpdeskListAsync.when(
                    data: (helpdeskList) async {
                      String? selectedHelpdeskId = _ticket!.assignedTo;
                      if (helpdeskList.isEmpty) {
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
                                  title: const Text('Assign ke Helpdesk'),
                                  content: SizedBox(
                                    width: double.maxFinite,
                                    height: 300,
                                    child: Scrollbar(
                                      thumbVisibility: true,
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: helpdeskList.length,
                                        itemBuilder: (c, i) {
                                          final hd = helpdeskList[i];
                                          return RadioListTile<String>(
                                            value: hd.id,
                                            groupValue: selectedHelpdeskId,
                                            title: Text(hd.fullName ?? 'Tanpa Nama'),
                                            onChanged: (v) {
                                              setSt(() => selectedHelpdeskId = v);
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Batal')),
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
                                      child: const Text('Assign'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );
                      }
                    },
                    loading: () => showDialog(
                      context: context,
                      builder: (ctx) => const AlertDialog(content: CircularProgressIndicator()),
                    ),
                    error: (err, stack) => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error memuat Helpdesk: $err')),
                    ),
                  );
                }
              },
              itemBuilder: (ctx) {
                final items = <PopupMenuEntry<String>>[
                  const PopupMenuItem(value: 'change_status', child: Text('Ubah Status')),
                ];
                if (role == 'admin') {
                  items.add(const PopupMenuItem(value: 'assign', child: Text('Assign ke Helpdesk')));
                }
                return items;
              },
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _ticket == null
              ? const Center(child: Text('Tiket tidak ditemukan atau sudah dihapus'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_ticket!.title, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _StatusBadge(status: _ticket!.status),
                          const SizedBox(width: 8),
                          if (_ticket!.assignedTo != null)
                            Flexible(
                              child: Consumer(
                                builder: (ctx, cRef, _) {
                                  final pAsync = cRef.watch(profileProvider(_ticket!.assignedTo!));
                                  return pAsync.when(
                                    data: (p) => Text(
                                      'Assignee: ${p?.fullName ?? 'Helpdesk'}',
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    loading: () => const Text('Assignee: ...', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                    error: (_, __) => Text('Assignee: ${_ticket!.assignedTo}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(_ticket!.description ?? ''),
                      const SizedBox(height: 12),

                      // === Attachments: tampilkan dari tabel baru dulu, fallback ke image_url lama ===
                      attachmentsAsync.when(
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (attachments) {
                          if (attachments.isNotEmpty) {
                            return AttachmentGrid(attachments: attachments);
                          }
                          // Fallback: tiket lama dengan image_url
                          if (_ticket!.imageUrl != null) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Lampiran:', style: TextStyle(fontWeight: FontWeight.w600)),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(MaterialPageRoute(
                                      builder: (_) => Scaffold(
                                        backgroundColor: Colors.black,
                                        appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white),
                                        body: Center(child: Image.network(_ticket!.imageUrl!)),
                                      ),
                                    ));
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(_ticket!.imageUrl!, height: 200, width: double.infinity, fit: BoxFit.cover),
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),

                      // === Comments section ===
                      const Text('Komentar', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Builder(builder: (ctx) {
                        final commentsAsync = ref.watch(commentsProvider(widget.id));
                        return commentsAsync.when(
                          data: (comments) {
                            return Expanded(
                              child: ListView.builder(
                                itemCount: comments.length,
                                itemBuilder: (ctx, idx) {
                                  final c = comments[idx];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
                                    child: Builder(builder: (ctx) {
                                      final authState = ref.watch(authNotifierProvider);
                                      final myUserId = authState.user?.id;
                                      final isMe = myUserId != null && myUserId == c.userId;
                                      final profileAsync = ref.watch(profileProvider(c.userId ?? ''));

                                      return profileAsync.when(
                                        data: (profile) {
                                          final name = profile?.fullName ?? (isMe ? 'Saya' : 'User');
                                          return _ChatBubble(name: name, message: c.message, time: DateFormatter.formatShort(c.createdAt), isMe: isMe);
                                        },
                                        loading: () => const SizedBox.shrink(),
                                        error: (_, _) {
                                          return _ChatBubble(name: isMe ? 'Saya' : 'User', message: c.message, time: DateFormatter.formatShort(c.createdAt), isMe: isMe);
                                        },
                                      );
                                    }),
                                  );
                                },
                              ),
                            );
                          },
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (e, st) => const Center(child: Text('Gagal memuat komentar')),
                        );
                      }),

                      // Comment input
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _commentCtl,
                              decoration: const InputDecoration(hintText: 'Tulis komentar...'),
                            ),
                          ),
                          IconButton(onPressed: _addComment, icon: const Icon(Icons.send)),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  Color get _color {
    switch (status.toLowerCase()) {
      case 'open': return Colors.orange;
      case 'assigned': return Colors.blue;
      case 'in progress': return Colors.purple;
      case 'resolved': return Colors.teal;
      case 'closed': return Colors.green;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _color),
      ),
      child: Text(status, style: TextStyle(color: _color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String name;
  final String message;
  final String time;
  final bool isMe;
  const _ChatBubble({required this.name, required this.message, required this.time, required this.isMe});

  @override
  Widget build(BuildContext context) {
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
                Text(message, style: TextStyle(color: isMe ? Theme.of(context).colorScheme.onPrimary : Colors.black87)),
                const SizedBox(height: 6),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe
                        ? Theme.of(context).colorScheme.onPrimary.withAlpha((0.75 * 255).round())
                        : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
