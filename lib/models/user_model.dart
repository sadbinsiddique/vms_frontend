/// Represents an administrative user logged into the VMS system.
class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? avatarUrl;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'Fleet Manager',
      avatarUrl: json['avatarUrl']?.toString() ?? json['avatar_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
    };
  }

  /// Default mock administrator fallback if session is empty.
  static const UserModel mockAdmin = UserModel(
    id: 'usr_admin_001',
    name: 'Alice Smith',
    email: 'admin@vms.com',
    role: 'Fleet Manager',
  );
}
