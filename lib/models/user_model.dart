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

  /// Default mock administrator for foundation/demo purposes.
  static const UserModel mockAdmin = UserModel(
    id: 'usr_admin_001',
    name: 'Sarah Connor',
    email: 'admin@vms.com',
    role: 'Fleet Manager',
  );
}

