class ProfileModel {
  final String id;
  final String? fullName; // Sesuai kolom full_name
  final String role;      // Sesuai constraint role: Admin, Helpdesk, User

  ProfileModel({
    required this.id,
    this.fullName,
    required this.role,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'],
      fullName: json['full_name'], // Ambil dari kolom full_name
      role: json['role'] ?? 'User',
    );
  }
}