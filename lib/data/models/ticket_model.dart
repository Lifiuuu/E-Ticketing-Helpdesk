class TicketModel {
  final String id;
  final String? userId;
  final String title;
  final String? description;
  final String status;      // Status: Open, In Progress, Resolved, Closed
  final String? imageUrl;   // Sesuai kolom image_url untuk upload laporan
  final DateTime createdAt;
  final String? assignedTo; // UUID dari profil petugas

  TicketModel({
    required this.id,
    this.userId,
    required this.title,
    this.description,
    required this.status,
    this.imageUrl,
    required this.createdAt,
    this.assignedTo,
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
    };
  }
}