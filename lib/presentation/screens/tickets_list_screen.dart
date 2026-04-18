import 'package:flutter/material.dart';
import '../../data/ticket/dummy_ticket_service.dart';
import 'package:go_router/go_router.dart';

class TicketsListScreen extends StatefulWidget {
  const TicketsListScreen({super.key});

  @override
  State<TicketsListScreen> createState() => _TicketsListScreenState();
}

class _TicketsListScreenState extends State<TicketsListScreen> {
  final DummyTicketService _service = DummyTicketService();
  final List<Ticket> _items = [];
  final ScrollController _ctrl = ScrollController();
  int _page = 1;
  final int _pageSize = 10;
  bool _loading = false;
  bool _hasMore = true;
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    _loadPage();
    _ctrl.addListener(() {
      if (_ctrl.position.pixels > _ctrl.position.maxScrollExtent - 200 && !_loading && _hasMore) {
        _loadPage();
      }
    });
  }

  Future<void> _loadPage() async {
    setState(() => _loading = true);
    final pageItems = await _service.fetchTickets(page: _page, pageSize: _pageSize);
    setState(() {
      _items.addAll(pageItems);
      _loading = false;
      _page++;
      if (pageItems.length < _pageSize) _hasMore = false;
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayed = _statusFilter == null ? _items : _items.where((t) => t.status == _statusFilter).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('List Tiket'),
        actions: [
          PopupMenuButton<String?>(
            onSelected: (v) => setState(() => _statusFilter = v),
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: null, child: Text('All')),
              const PopupMenuItem(value: 'Open', child: Text('Open')),
              const PopupMenuItem(value: 'In Progress', child: Text('In Progress')),
              const PopupMenuItem(value: 'Assigned', child: Text('Assigned')),
              const PopupMenuItem(value: 'Closed', child: Text('Closed')),
            ],
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _items.clear();
          _page = 1;
          _hasMore = true;
          await _loadPage();
        },
        child: ListView.builder(
          controller: _ctrl,
          itemCount: displayed.length + (_hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= displayed.length) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final t = displayed[index];
            return ListTile(
              leading: CircleAvatar(child: Text('${t.id}')),
              title: Text(t.title),
              subtitle: Text(t.description, maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: Text(t.status),
              onTap: () => context.go('/ticket/${t.id}'),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/create-ticket'),
        child: const Icon(Icons.add),
        tooltip: 'Create Ticket',
      ),
    );
  }
}
