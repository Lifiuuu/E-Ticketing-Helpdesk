import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder stats
    final total = 128;
    final open = 24;
    final inProgress = 42;
    final closed = 62;

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hello, welcome to E-Ticketing', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatCard(label: 'Total', value: total),
                _StatCard(label: 'Open', value: open),
                _StatCard(label: 'In Progress', value: inProgress),
                _StatCard(label: 'Closed', value: closed),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Recent Tickets', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) => ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text('Ticket #${1000 + index}'),
                  subtitle: const Text('Short description of the issue'),
                  trailing: const Text('Open'),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed('/profile'),
        child: const Icon(Icons.person),
        tooltip: 'Profile',
      ),
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
