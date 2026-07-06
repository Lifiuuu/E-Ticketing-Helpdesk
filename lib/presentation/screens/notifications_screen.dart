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
  bool _isDeleteMode = false;
  Set<String> _selectedIds = {};
  bool _isDeleting = false;

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
      appBar: AppBar(
        leading: _isDeleteMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() {
                  _isDeleteMode = false;
                  _selectedIds.clear();
                }),
              )
            : null,
        title: Text(_isDeleteMode ? '${_selectedIds.length} Terpilih' : 'Notifications'),
        actions: [
          if (_isDeleteMode) ...[
            notifsAsync.when(
              data: (list) => IconButton(
                icon: const Icon(Icons.select_all),
                tooltip: 'Pilih Semua',
                onPressed: () {
                  setState(() {
                    if (_selectedIds.length == list.length) {
                      _selectedIds.clear();
                    } else {
                      _selectedIds = list.map((n) => n.id).toSet();
                    }
                  });
                },
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            IconButton(
              icon: _isDeleting 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                  : const Icon(Icons.delete),
              tooltip: 'Hapus',
              onPressed: _selectedIds.isEmpty || _isDeleting
                  ? null
                  : () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Hapus Notifikasi'),
                          content: Text('Yakin ingin menghapus ${_selectedIds.length} notifikasi ini?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Hapus')),
                          ],
                        )
                      );
                      if (confirm == true) {
                        setState(() => _isDeleting = true);
                        try {
                          await ref.read(notificationRepoProvider).deleteMultipleNotifications(_selectedIds.toList());
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${_selectedIds.length} notifikasi berhasil dihapus')));
                            setState(() {
                              _isDeleteMode = false;
                              _selectedIds.clear();
                            });
                            ref.invalidate(notificationsStreamProvider);
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menghapus notifikasi: $e')));
                          }
                        } finally {
                          if (mounted) setState(() => _isDeleting = false);
                        }
                      }
                    },
            ),
          ]
        ],
      ),
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
              final isSelected = _selectedIds.contains(n.id);
              return ListTile(
                selected: isSelected,
                selectedTileColor: Colors.red.withOpacity(0.1),
                leading: _isDeleteMode
                    ? Checkbox(
                        value: isSelected,
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              _selectedIds.add(n.id);
                            } else {
                              _selectedIds.remove(n.id);
                              if (_selectedIds.isEmpty) _isDeleteMode = false;
                            }
                          });
                        },
                      )
                    : null,
                title: Text(n.title),
                subtitle: Text(n.message),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(n.timeAgo()),
                  ],
                ),
                onLongPress: () {
                  if (!_isDeleteMode) {
                    setState(() {
                      _isDeleteMode = true;
                      _selectedIds.add(n.id);
                    });
                  }
                },
                onTap: () async {
                  if (_isDeleteMode) {
                    setState(() {
                      if (isSelected) {
                        _selectedIds.remove(n.id);
                        if (_selectedIds.isEmpty) _isDeleteMode = false;
                      } else {
                        _selectedIds.add(n.id);
                      }
                    });
                  } else {
                    // Navigate to ticket detail
                    final router = GoRouter.of(context);
                    if (n.ticketId != null && n.ticketId!.isNotEmpty) {
                      router.push('/ticket/${Uri.encodeComponent(n.ticketId!)}');
                    }
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
