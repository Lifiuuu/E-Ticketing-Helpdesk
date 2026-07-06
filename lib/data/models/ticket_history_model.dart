class TicketHistoryModel {
  final String id;
  final String ticketId;
  final String? changedBy; // UUID of the user who made the change
  final String fieldChanged; // 'status', 'assigned_to', etc.
  final String? oldValue;
  final String? newValue;
  final DateTime createdAt;

  TicketHistoryModel({
    required this.id,
    required this.ticketId,
    this.changedBy,
    required this.fieldChanged,
    this.oldValue,
    this.newValue,
    required this.createdAt,
  });

  factory TicketHistoryModel.fromJson(Map<String, dynamic> json) {
    return TicketHistoryModel(
      id: json['id']?.toString() ?? '',
      ticketId: json['ticket_id']?.toString() ?? '',
      changedBy: json['changed_by']?.toString(),
      fieldChanged: json['field_changed']?.toString() ?? '',
      oldValue: json['old_value']?.toString(),
      newValue: json['new_value']?.toString(),
      createdAt: DateTime.parse(
          json['created_at']?.toString() ?? DateTime.now().toIso8601String()),
    );
  }

  /// Human-readable label for the changed field
  String get fieldLabel {
    switch (fieldChanged) {
      case 'status':
        return 'Status';
      case 'assigned_to':
        return 'Assignee';
      default:
        return fieldChanged;
    }
  }
}
