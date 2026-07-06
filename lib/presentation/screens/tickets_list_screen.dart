import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/auth_provider.dart';
import 'package:projectmobile/data/providers/provider.dart';
import 'package:projectmobile/presentation/widgets/bottom_refresh_listener.dart';

class TicketsListScreen extends ConsumerStatefulWidget {
  const TicketsListScreen({super.key});

  @override
  ConsumerState<TicketsListScreen> createState() => _TicketsListScreenState();
}

class _TicketsListScreenState extends ConsumerState<TicketsListScreen> {
  String? _statusFilter;
  String? _helpdeskFilter; // Hanya digunakan oleh Admin
  bool _isDeleteMode = false;
  Set<String> _selectedTickets = {};
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);
    final ticketsAsync = ref.watch(ticketsStreamProvider);
    final isAdmin = auth.role.toLowerCase() == 'admin';
    final isUser = auth.role.toLowerCase() == 'user';

    // Compute displayed tickets
    List<dynamic> displayedTickets = [];
    if (ticketsAsync.hasValue) {
      final items = ticketsAsync.value!;
      final filterVal = _statusFilter?.trim().toLowerCase();
      displayedTickets = (filterVal == null || filterVal.isEmpty || filterVal == 'all')
          ? items
          : items.where((t) => (t.status ?? '').trim().toLowerCase() == filterVal).toList();

      if (isAdmin && _helpdeskFilter != null && _helpdeskFilter!.isNotEmpty) {
        displayedTickets = displayedTickets.where((t) => t.assignedTo == _helpdeskFilter).toList();
      }
    }

    return Scaffold(
      appBar: AppBar(
        leading: _isDeleteMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() {
                  _isDeleteMode = false;
                  _selectedTickets.clear();
                }),
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/dashboard'),
              ),
        title: Text(_isDeleteMode ? '${_selectedTickets.length} Terpilih' : 'List Tiket'),
        actions: [
          if (_isDeleteMode) ...[
            IconButton(
              icon: const Icon(Icons.select_all),
              tooltip: 'Pilih Semua',
              onPressed: () {
                setState(() {
                  if (_selectedTickets.length == displayedTickets.length) {
                    _selectedTickets.clear();
                  } else {
                    _selectedTickets = displayedTickets.map((t) => t.id.toString()).toSet();
                  }
                });
              },
            ),
            IconButton(
              icon: _isDeleting 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                  : const Icon(Icons.delete),
              tooltip: 'Hapus',
              onPressed: _selectedTickets.isEmpty || _isDeleting
                  ? null
                  : () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Hapus Tiket'),
                          content: Text('Yakin ingin menghapus ${_selectedTickets.length} tiket ini?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Hapus')),
                          ],
                        )
                      );
                      if (confirm == true) {
                        setState(() => _isDeleting = true);
                        try {
                          final repo = ref.read(ticketRepoProvider);
                          for (final id in _selectedTickets) {
                            await repo.deleteTicket(id);
                          }
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${_selectedTickets.length} tiket berhasil dihapus')));
                            setState(() {
                              _isDeleteMode = false;
                              _selectedTickets.clear();
                            });
                            ref.invalidate(ticketsStreamProvider);
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menghapus tiket: $e')));
                          }
                        } finally {
                          if (mounted) setState(() => _isDeleting = false);
                        }
                      }
                    },
            ),
          ] else ...[
          // Filter by Helpdesk — hanya Admin
          if (isAdmin)
            ref.watch(helpdeskUsersProvider).when(
              data: (helpdeskList) {
                return IconButton(
                  tooltip: 'Filter Helpdesk',
                  icon: Stack(
                    children: [
                      const Icon(Icons.person_search),
                      if (_helpdeskFilter != null)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (ctx) {
                        String searchQuery = '';
                        return StatefulBuilder(
                          builder: (context, setModalState) {
                            final filteredList = helpdeskList.where((hd) {
                              final name = (hd.fullName ?? hd.id).toLowerCase();
                              return name.contains(searchQuery.toLowerCase());
                            }).toList();

                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: MediaQuery.of(context).viewInsets.bottom,
                                top: 16,
                                left: 16,
                                right: 16,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 4,
                                    margin: const EdgeInsets.only(bottom: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const Text('Pilih Helpdesk', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 16),
                                  TextField(
                                    decoration: InputDecoration(
                                      hintText: 'Cari nama helpdesk...',
                                      prefixIcon: const Icon(Icons.search),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                                    ),
                                    onChanged: (val) => setModalState(() => searchQuery = val),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    constraints: BoxConstraints(
                                      maxHeight: MediaQuery.of(context).size.height * 0.4,
                                    ),
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: filteredList.length + 1,
                                      itemBuilder: (context, index) {
                                        if (index == 0) {
                                          return ListTile(
                                            title: const Text('Semua Helpdesk', style: TextStyle(fontWeight: FontWeight.bold)),
                                            trailing: _helpdeskFilter == null ? const Icon(Icons.check, color: Colors.blue) : null,
                                            onTap: () {
                                              setState(() => _helpdeskFilter = null);
                                              Navigator.pop(context);
                                            },
                                          );
                                        }
                                        final hd = filteredList[index - 1];
                                        final isSelected = _helpdeskFilter == hd.id;
                                        return ListTile(
                                          title: Text(hd.fullName ?? hd.id),
                                          trailing: isSelected ? const Icon(Icons.check, color: Colors.blue) : null,
                                          onTap: () {
                                            setState(() => _helpdeskFilter = hd.id);
                                            Navigator.pop(context);
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const SizedBox(width: 40),
              error: (_, __) => const SizedBox(width: 40),
            ),

          // Filter by Status
          PopupMenuButton<String?>(
            onSelected: (v) {
              debugPrint('Filter selected: $v (${v.runtimeType})');
              setState(() => _statusFilter = v);
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: 'All', child: Text('All')),
              const PopupMenuItem(value: 'Open', child: Text('Open')),
              const PopupMenuItem(value: 'In Progress', child: Text('In Progress')),
              const PopupMenuItem(value: 'Resolved', child: Text('Resolved')),
              const PopupMenuItem(value: 'Closed', child: Text('Closed')),
            ],
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter Status',
          ),
          ],
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(ticketsStreamProvider),
        child: ticketsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data: (items) {
            if (displayedTickets.isEmpty) {
              return const Center(child: Text('Tidak ada tiket.'));
            }

            return BottomRefreshListener(
              onBottomReached: () async => ref.invalidate(ticketsStreamProvider),
              child: ListView.builder(
                itemCount: displayedTickets.length,
                itemBuilder: (context, index) {
                  final t = displayedTickets[index];
                  final isSelected = _selectedTickets.contains(t.id.toString());
                  
                  return ListTile(
                    selected: isSelected,
                    selectedTileColor: Colors.red.withOpacity(0.1),
                    leading: _isDeleteMode
                        ? Checkbox(
                            value: isSelected,
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  _selectedTickets.add(t.id.toString());
                                } else {
                                  _selectedTickets.remove(t.id.toString());
                                  if (_selectedTickets.isEmpty) _isDeleteMode = false;
                                }
                              });
                            },
                          )
                        : CircleAvatar(
                            backgroundColor: Colors.blue.withOpacity(0.1),
                            child: const Icon(Icons.confirmation_number, color: Colors.blue),
                          ),
                    title: Text(t.title),
                    subtitle: Text(t.description ?? 'Tanpa deskripsi',
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: _StatusBadge(status: t.status),
                    onLongPress: () {
                      if (!_isDeleteMode) {
                        setState(() {
                          _isDeleteMode = true;
                          _selectedTickets.add(t.id.toString());
                        });
                      }
                    },
                    onTap: () {
                      if (_isDeleteMode) {
                        setState(() {
                          if (isSelected) {
                            _selectedTickets.remove(t.id.toString());
                            if (_selectedTickets.isEmpty) _isDeleteMode = false;
                          } else {
                            _selectedTickets.add(t.id.toString());
                          }
                        });
                      } else {
                        context.push('/ticket/${t.id}');
                      }
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
      
      // FAB: Create Ticket — semua role kini bisa (User, Helpdesk, Admin)
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/create-ticket'),
        tooltip: 'Buat Tiket',
        child: const Icon(Icons.add),
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
      case 'in progress': return Colors.purple;
      case 'resolved': return Colors.teal;
      case 'closed': return Colors.green;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _color, width: 1),
      ),
      child: Text(status, style: TextStyle(fontSize: 11, color: _color, fontWeight: FontWeight.w600)),
    );
  }
}