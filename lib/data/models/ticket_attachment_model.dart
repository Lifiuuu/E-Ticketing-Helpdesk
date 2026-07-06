class TicketAttachmentModel {
  final String id;
  final String ticketId;
  final String fileUrl;
  final String? fileName;
  final int? fileSize;
  final DateTime createdAt;

  TicketAttachmentModel({
    required this.id,
    required this.ticketId,
    required this.fileUrl,
    this.fileName,
    this.fileSize,
    required this.createdAt,
  });

  factory TicketAttachmentModel.fromJson(Map<String, dynamic> json) {
    return TicketAttachmentModel(
      id: json['id']?.toString() ?? '',
      ticketId: json['ticket_id']?.toString() ?? '',
      fileUrl: json['file_url']?.toString() ?? '',
      fileName: json['file_name']?.toString(),
      fileSize: json['file_size'] != null ? (json['file_size'] as num).toInt() : null,
      createdAt: DateTime.parse(
          json['created_at']?.toString() ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
        'ticket_id': ticketId,
        'file_url': fileUrl,
        'file_name': fileName,
        'file_size': fileSize,
      };
}
