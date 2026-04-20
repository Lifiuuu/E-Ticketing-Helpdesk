class CommentModel {
  final String id;
  final String ticketId;
  final String? userId;
  final String message;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.ticketId,
    this.userId,
    required this.message,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] ?? '').toString();
    final ticketId = (json['ticket_id'] ?? '').toString();
    final userId = json['user_id']?.toString();
    final message = (json['message'] ?? '').toString();
    final createdAtRaw = json['created_at'] ?? json['createdAt'] ?? DateTime.now().toIso8601String();
    final createdAt = DateTime.parse(createdAtRaw.toString());

    return CommentModel(
      id: id,
      ticketId: ticketId,
      userId: userId,
      message: message,
      createdAt: createdAt,
    );
  }
}