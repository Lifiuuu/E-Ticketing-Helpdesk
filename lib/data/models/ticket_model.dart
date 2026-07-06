class TicketModel {
  final String id;
  final String? userId;
  final String title;
  final String? description;
  final String status;      // Status: Open, In Progress, Resolved, Closed
  final String? imageUrl;   // Legacy field — tiket lama; tiket baru pakai tabel ticket_attachments
  final DateTime createdAt;
  final String? assignedTo; // UUID dari profil petugas
  final String? reporterId; // UUID pelapor (diisi jika Helpdesk/Admin yang buat tiket)
  final bool isDeleted;     // Soft delete (FR-016)

  TicketModel({
    required this.id,
    this.userId,
    required this.title,
    this.description,
    required this.status,
    this.imageUrl,
    required this.createdAt,
    this.assignedTo,
    this.reporterId,
    this.isDeleted = false,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      description: json['description'],
      status: json['status'] ?? 'Open',
      imageUrl: json['image_url'],
      createdAt: DateTime.parse(json['created_at']),
      assignedTo: json['assigned_to'],
      reporterId: json['reporter_id']?.toString(),
      isDeleted: json['is_deleted'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'title': title,
      'description': description,
      'status': status,
      'image_url': imageUrl,
      'assigned_to': assignedTo,
      'reporter_id': reporterId,
      'is_deleted': isDeleted,
    };
  }
}