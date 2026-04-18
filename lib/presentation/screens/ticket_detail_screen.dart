import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/ticket/dummy_ticket_service.dart';
import '../../core/auth/auth_provider.dart';

class TicketDetailScreen extends StatefulWidget {
  final int id;
  const TicketDetailScreen({super.key, required this.id});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  final DummyTicketService _service = DummyTicketService();
  Ticket? _ticket;
  bool _loading = true;
  final _commentCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _ticket = await _service.getTicketById(widget.id);
    setState(() => _loading = false);
  }

  Future<void> _addComment() async {
    final text = _commentCtl.text.trim();
    if (text.isEmpty) return;
    await _service.addComment(widget.id, text);
    _commentCtl.clear();
    await _load();
  }

  Future<void> _assign(String assignee) async {
    await _service.assignTicket(widget.id, assignee);
    await _load();
  }

  Future<void> _changeStatus(String status) async {
    await _service.updateStatus(widget.id, status);
    await _load();
  }

  @override
  void dispose() {
    _commentCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Tiket')),
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
                      if (_ticket!.assignee != null) Text('Assignee: ${_ticket!.assignee}'),
                      const SizedBox(height: 12),
                      // Admin controls
                      Builder(builder: (ctx) {
                        final auth = Provider.of<AuthProvider>(ctx);
                        if (auth.role != 'admin') return const SizedBox.shrink();
                        String statusVal = _ticket!.status;
                        final _assigneeCtl = TextEditingController(text: _ticket!.assignee ?? '');
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Admin Controls', style: TextStyle(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                DropdownButton<String>(
                                  value: statusVal,
                                  items: ['Open', 'In Progress', 'Assigned', 'Closed']
                                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                      .toList(),
                                  onChanged: (v) {
                                    if (v == null) return;
                                    _changeStatus(v);
                                  },
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(controller: _assigneeCtl, decoration: const InputDecoration(hintText: 'Assign to')),
                                ),
                                ElevatedButton(onPressed: () => _assign(_assigneeCtl.text.trim()), child: const Text('Assign')),
                              ],
                            ),
                            const SizedBox(height: 12),
                          ],
                        );
                      }),
                      Text(_ticket!.description),
                      const SizedBox(height: 12),
                      if (_ticket!.attachments.isNotEmpty) ...[
                        const Text('Attachments:'),
                        const SizedBox(height: 8),
                        Wrap(children: _ticket!.attachments.map((a) => Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Chip(label: Text(a)),
                        )).toList()),
                        const SizedBox(height: 12),
                      ],
                      const Text('Comments', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView(
                          children: _ticket!.comments.map((c) => ListTile(title: Text(c))).toList(),
                        ),
                      ),
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
