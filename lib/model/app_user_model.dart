import '../../domain/entities/app_user.dart';

class AppUserModel extends AppUser {
  const AppUserModel({
    required super.userId,
    required super.email,
    required super.role,
    super.passwordHash,
    super.authId,
  });

  factory AppUserModel.fromJson(Map<String, dynamic> json) {
    return AppUserModel(
      userId: json['user_id'] as int,
      email: json['email'] as String,
      role: json['role'] as String,
      passwordHash: json['password_hash'] as String?,
      authId: json['auth_id'] as String?,
    );
  }
}
