import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Đăng nhập với email & password
  Future<Map<String, dynamic>> signIn(String email, String password) async {
    // 1. Gọi Supabase auth
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception("Đăng nhập thất bại. Kiểm tra lại email/mật khẩu.");
    }

    final userId = response.user!.id;

    // 2. Truy vấn bảng `app_user` để lấy user_id và role
    final userData = await _supabase
        .from('app_user')
        .select('user_id, role')
        .eq('auth_id', userId) // auth_id mapping với supabase user id
        .single();

    if (userData == null) {
      throw Exception("Không tìm thấy thông tin người dùng trong hệ thống.");
    }

    // 3. (Optional) Lấy name từ bảng student nếu có
    final studentData = await _supabase
        .from('student')
        .select('name')
        .eq('user_id', userData['user_id'])
        .maybeSingle();

    return {
      'id': userData['user_id'],
      'role': userData['role'], // admin | organizer | student
      'name': studentData?['name'], // Có thể null nếu không phải student
    };
  }

  /// Đăng xuất
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  /// Lấy user hiện tại (nếu có)
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    final userData = await _supabase
        .from('app_user')
        .select('user_id, role')
        .eq('auth_id', user.id)
        .single();

    if (userData == null) return null;

    // (Optional) Lấy name từ bảng student nếu có
    final studentData = await _supabase
        .from('student')
        .select('name')
        .eq('user_id', userData['user_id'])
        .maybeSingle();

    return {
      'id': userData['user_id'],
      'role': userData['role'],
      'name': studentData?['name'],
    };
  }
}