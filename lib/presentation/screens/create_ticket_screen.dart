import 'package:flutter/material.dart';
import '../../data/ticket/dummy_ticket_service.dart';
import 'package:go_router/go_router.dart';

class CreateTicketScreen extends StatefulWidget {
  const CreateTicketScreen({super.key});

  @override
  State<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtl = TextEditingController();
  final _descCtl = TextEditingController();
  final DummyTicketService _service = DummyTicketService();
  bool _loading = false;
  bool _hasAttachment = false;

  @override
  void dispose() {
    _titleCtl.dispose();
    _descCtl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await _service.addTicket(_titleCtl.text.trim(), _descCtl.text.trim(), attachments: _hasAttachment ? ['image-placeholder'] : null);
    setState(() => _loading = false);
    context.go('/tickets');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Tiket')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleCtl,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtl,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 4,
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Checkbox(value: _hasAttachment, onChanged: (v) => setState(() => _hasAttachment = v ?? false)),
                  const SizedBox(width: 8),
                  const Text('Attach image (placeholder)'),
                ],
              ),
              const SizedBox(height: 12),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(onPressed: _submit, child: const Text('Submit')),
            ],
          ),
        ),
      ),
    );
  }
}
