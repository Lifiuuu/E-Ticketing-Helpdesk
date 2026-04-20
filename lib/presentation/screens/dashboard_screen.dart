import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/auth_provider.dart';
import 'package:projectmobile/data/providers/provider.dart'; 
import 'package:projectmobile/presentation/widgets/bottom_refresh_listener.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);
    final ticketsAsync = ref.watch(ticketsStreamProvider); // Ambil data asli

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          // Notifications icon with unread badge
          Builder(builder: (ctx) {
            final notifsAsync = ref.watch(notificationsStreamProvider);
            return notifsAsync.when(
              data: (list) {
                final unread = list.where((n) => !n.isRead).length;
                return IconButton(
                  onPressed: () => context.push('/notifications'),
                  icon: Stack(
                    children: [
                      const Icon(Icons.notifications),
                      if (unread > 0)
                        Positioned(
                          right: 0,
                          child: CircleAvatar(
                            radius: 8,
                            backgroundColor: Colors.red,
                            child: Text('$unread', style: const TextStyle(fontSize: 10, color: Colors.white)),
                          ),
                        ),
                    ],
                  ),
                  tooltip: 'Notifications',
                );
              },
              loading: () => IconButton(onPressed: () => context.push('/notifications'), icon: const Icon(Icons.notifications)),
              error: (_, _) => IconButton(onPressed: () => context.push('/notifications'), icon: const Icon(Icons.notifications)),
            );
          }),
          // Profile button available for all roles
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Profile',
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: BottomRefreshListener(
        onBottomReached: () => ref.invalidate(ticketsStreamProvider),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Halo, ${auth.username ?? 'User'}!', style: Theme.of(context).textTheme.titleLarge),
                const Text('Selamat datang di E-Ticketing Helpdesk'),
                const SizedBox(height: 16),

                // Menggunakan AsyncValue Riverpod untuk handle Loading/Data/Error
                ticketsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Text('Gagal memuat data: $err'),
                  data: (tickets) {
                    // Hitung statistik asli berdasarkan status
                    final total = tickets.length;
                    final open = tickets.where((t) => t.status == 'Open').length;
                    final inProgress = tickets.where((t) => t.status == 'In Progress').length;
                    final closed = tickets.where((t) => t.status == 'Closed' || t.status == 'Resolved').length;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _StatCard(label: 'Total', value: total),
                        _StatCard(label: 'Open', value: open),
                        _StatCard(label: 'Diproses', value: inProgress),
                        _StatCard(label: 'Selesai', value: closed),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
                // Button to view full ticket list
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton.icon(
                    onPressed: () => context.push('/tickets'),
                    icon: const Icon(Icons.list),
                    label: const Text('Lihat Semua Tiket'),
                  ),
                ),
                const SizedBox(height: 12),
                // ... (Bagian Recent Tickets bisa kamu sesuaikan dengan data `tickets` nanti)
              ],
            ),
          ),
        ),
      ),
      // Show Create Ticket button only for users
      floatingActionButton: auth.role.toLowerCase() == 'user'
          ? FloatingActionButton(
              onPressed: () => context.push('/create-ticket'),
              tooltip: 'Buat Tiket',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}


  class _StatCard extends StatelessWidget {
    final String label;
    final int value;
    const _StatCard({required this.label, required this.value});

    @override
    Widget build(BuildContext context) {
      return Expanded(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Column(
              children: [
                Text(label, style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 8),
                Text('$value', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      );
    }
  }

