class User {
  final int userId;
  final String username;
  final String password;
  final String role; // admin / organizer / student

  User({
    required this.userId,
    required this.username,
    required this.password,
    required this.role,
  });
}