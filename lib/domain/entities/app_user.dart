class AppUser {
  final int userId;
  final String email;
  final String role;
  final String? passwordHash;
  final String? authId;

  const AppUser({
    required this.userId,
    required this.email,
    required this.role,
    this.passwordHash,
    this.authId,
  });

  bool get isAdmin => role.toLowerCase() == 'admin';
  bool get isOrganizer => role.toLowerCase() == 'organizer';
  bool get isStudent => role.toLowerCase() == 'student';

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      userId: json['user_id'] as int,
      email: json['email'] as String,
      role: json['role'] as String,
      passwordHash: json['password_hash'] as String?,
      authId: json['auth_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'email': email,
      'role': role,
      'password_hash': passwordHash,
      'auth_id': authId,
    };
  }
}
