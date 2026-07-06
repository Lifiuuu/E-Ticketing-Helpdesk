class ProfileModel {
  final String id;
  final String? fullName; // Sesuai kolom full_name
  final String role;      // Sesuai constraint role: Admin, Helpdesk, User
  final bool isActive;    // Kolom is_active di tabel profiles
  final String? phoneNumber; // Kolom phone_number di tabel profiles
  final String? avatarUrl;   // Kolom avatar_url di tabel profiles
  final String? email;       // Kolom email di tabel profiles (jika ditambahkan)

  ProfileModel({
    required this.id,
    this.fullName,
    required this.role,
    this.isActive = true,
    this.phoneNumber,
    this.avatarUrl,
    this.email,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'],
      fullName: json['full_name'], // Ambil dari kolom full_name
      role: json['role'] ?? 'User',
      isActive: json['is_active'] ?? true,
      phoneNumber: json['phone_number']?.toString(),
      avatarUrl: json['avatar_url']?.toString(),
      email: json['email']?.toString(),
    );
  }
}