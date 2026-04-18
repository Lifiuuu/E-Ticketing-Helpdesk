import '../../core/notification/notification_service.dart';

class Ticket {
  final int id;
  final String title;
  final String description;
  String status;
  String? assignee;
  final DateTime createdAt;
  final List<String> attachments;
  final List<String> comments;

  Ticket({
    required this.id,
    required this.title,
    required this.description,
    this.status = 'Open',
    this.assignee,
    DateTime? createdAt,
    List<String>? attachments,
    List<String>? comments,
  })  : createdAt = createdAt ?? DateTime.now(),
        attachments = attachments ?? [],
        comments = comments ?? [];
}

class DummyTicketService {
  static final DummyTicketService _instance = DummyTicketService._internal();
  factory DummyTicketService() => _instance;
  DummyTicketService._internal() {
    // seed some tickets
    for (var i = 0; i < 50; i++) {
      _tickets.add(Ticket(id: i + 1, title: 'Ticket #${i + 1}', description: 'Description for ticket ${i + 1}'));
    }
  }

  final List<Ticket> _tickets = [];

  Future<List<Ticket>> fetchTickets({required int page, required int pageSize}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final start = (page - 1) * pageSize;
    if (start >= _tickets.length) return [];
    final end = (start + pageSize).clamp(0, _tickets.length);
    return _tickets.sublist(start, end);
  }

  Future<Ticket?> getTicketById(int id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _tickets.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> assignTicket(int ticketId, String assignee) async {
    final t = await getTicketById(ticketId);
    if (t != null) {
      t.assignee = assignee;
      t.status = 'Assigned';
      NotificationService.instance.showNotification(ticketId, 'Ticket #${t.id} assigned to $assignee');
    }
    await Future.delayed(const Duration(milliseconds: 150));
  }

  Future<void> updateStatus(int ticketId, String status) async {
    final t = await getTicketById(ticketId);
    if (t != null) {
      t.status = status;
      NotificationService.instance.showNotification(ticketId, 'Ticket #${t.id} status: $status');
    }
    await Future.delayed(const Duration(milliseconds: 150));
  }

  Future<Ticket> addTicket(String title, String description, {List<String>? attachments}) async {
    final id = _tickets.isEmpty ? 1 : _tickets.map((t) => t.id).reduce((a, b) => a > b ? a : b) + 1;
    final ticket = Ticket(id: id, title: title, description: description, attachments: attachments);
    _tickets.insert(0, ticket);
    await Future.delayed(const Duration(milliseconds: 300));
    return ticket;
  }

  Future<void> addComment(int ticketId, String comment) async {
    final t = await getTicketById(ticketId);
    if (t != null) {
      t.comments.add(comment);
    }
    await Future.delayed(const Duration(milliseconds: 150));
  }
}
