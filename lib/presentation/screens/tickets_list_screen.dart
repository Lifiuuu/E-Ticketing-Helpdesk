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

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);
    final ticketsAsync = ref.watch(ticketsStreamProvider); // Ambil data asli

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        title: const Text('List Tiket'),
        actions: [
          // Filter pop-up buatanmu sudah bagus, biarkan saja
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
          ),
        ],
      ),
      body: RefreshIndicator(
        // Refresh data langsung dari provider
        onRefresh: () async => ref.refresh(ticketsStreamProvider),
        child: ticketsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data: (items) {
            // Logika filter status (treat null/empty/'all' as no-filter)
            final filterVal = _statusFilter?.trim().toLowerCase();
            final displayed = (filterVal == null || filterVal.isEmpty || filterVal == 'all')
              ? items
              : items.where((t) => (t.status ?? '').trim().toLowerCase() == filterVal).toList();

            debugPrint('tickets total: ${items.length}, displayed: ${displayed.length}, filter=$_statusFilter');

            if (displayed.isEmpty) return const Center(child: Text('Tidak ada tiket.'));

            return BottomRefreshListener(
              onBottomReached: () async => ref.invalidate(ticketsStreamProvider),
              child: ListView.builder(
                itemCount: displayed.length,
                itemBuilder: (context, index) {
                  final t = displayed[index];
                  return ListTile(
                    leading: CircleAvatar(child: Text(t.id.substring(0, 3))), // Ambil 3 huruf awal UUID
                    title: Text(t.title),
                    subtitle: Text(t.description ?? 'Tanpa deskripsi', maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: Text(t.status),
                    onTap: () => context.push('/ticket/${t.id}'), // Pakai PUSH agar bisa kembali (Back)
                  );
                },
              ),
            );
          },
        ),
      ),
      
      // LOGIKA HAK AKSES: Sembunyikan FAB jika bukan 'user' biasa
      floatingActionButton: auth.role.toLowerCase() == 'user' 
        ? FloatingActionButton(
            onPressed: () => context.push('/create-ticket'),
            tooltip: 'Create Ticket',
            child: const Icon(Icons.add),
          )
        : null, 
    );
  }
}