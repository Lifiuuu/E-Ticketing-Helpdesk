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
    final ticketsAsync = ref.watch(ticketsStreamProvider);
    final isAdmin = auth.role.toLowerCase() == 'admin';
    final isUser = auth.role.toLowerCase() == 'user';

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
                  tooltip: 'Notifikasi',
                );
              },
              loading: () => IconButton(onPressed: () => context.push('/notifications'), icon: const Icon(Icons.notifications)),
              error: (_, _) => IconButton(onPressed: () => context.push('/notifications'), icon: const Icon(Icons.notifications)),
            );
          }),
          // Settings button
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Pengaturan',
            onPressed: () => context.push('/settings'),
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
                Text('Halo, ${auth.username ?? 'User'}!',
                    style: Theme.of(context).textTheme.titleLarge),
                const Text('Selamat datang di E-Ticketing Helpdesk'),
                const SizedBox(height: 16),

                // FR-009: Statistik Tiket — 5 status
                ticketsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Text('Gagal memuat data: $err'),
                  data: (tickets) {
                    final total = tickets.length;
                    final open = tickets.where((t) => t.status == 'Open').length;
                    final assigned = tickets.where((t) => t.assignedTo != null && t.status != 'Closed' && t.status != 'Resolved').length;
                    final inProgress = tickets.where((t) => t.status == 'In Progress').length;
                    final closed = tickets.where((t) =>
                        t.status == 'Closed' || t.status == 'Resolved').length;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Total Card (Full Width)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue.shade700, Colors.blue.shade400],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.confirmation_number, color: Colors.white, size: 32),
                              const SizedBox(height: 12),
                              Text(
                                '$total',
                                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              const Text(
                                'Total Keseluruhan Tiket',
                                style: TextStyle(fontSize: 14, color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Status Grid
                        Row(
                          children: [
                            _StatCard(label: 'Open', value: open, color: Colors.orange, icon: Icons.fiber_new),
                            const SizedBox(width: 12),
                            _StatCard(label: 'Assigned', value: assigned, color: Colors.blue, icon: Icons.assignment_ind),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _StatCard(label: 'Diproses', value: inProgress, color: Colors.purple, icon: Icons.pending_actions),
                            const SizedBox(width: 12),
                            _StatCard(label: 'Selesai', value: closed, color: Colors.green, icon: Icons.check_circle_outline),
                          ],
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Tombol Lihat Semua Tiket
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/tickets'),
                    icon: const Icon(Icons.list),
                    label: const Text('Lihat Semua Tiket'),
                  ),
                ),

                // FR-007: Tombol Kelola Pengguna (hanya Admin)
                if (isAdmin) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => context.push('/users'),
                      icon: const Icon(Icons.manage_accounts),
                      label: const Text('Kelola Pengguna'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),

      // FAB: Create Ticket (Semua role)
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/create-ticket'),
        tooltip: 'Buat Tiket',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final IconData icon;
  const _StatCard({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              '$value',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
