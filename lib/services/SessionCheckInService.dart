import 'package:supabase_flutter/supabase_flutter.dart';

class SessionCheckInService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Hàm tạo một bản ghi check-in mới
  Future<bool> createCheckin({
    required int sessionId,
    required int studentId,
    required String method,
    // Bạn có thể thêm tham số vị trí (location) ở đây
  }) async {
    try {
      await _supabase.from('session_checkin').insert({
        'session_id': sessionId,
        'student_id': studentId,
        'method': method,
        'checkin_time': DateTime.now().toIso8601String(),
      });
      return true; // Trả về true nếu thành công
    } catch (e) {
      // In lỗi ra để debug
      print('Lỗi khi tạo check-in: $e');
      return false; // Trả về false nếu thất bại
    }
  }

  // Hàm lấy danh sách sinh viên cho một phiên (đã check-in và chưa check-in)
  // Đây là code ví dụ, bạn cần tạo một RPC function trên Supabase để chạy query LEFT JOIN
  Future<List<Map<String, dynamic>>> getCheckinStatusForSession(int sessionId) async {
    try {
      // Gọi một function trong Postgres (RPC) vì policy không hỗ trợ LEFT JOIN phức tạp
      final response = await _supabase.rpc(
        'get_session_attendance',
        params: {'session_id_param': sessionId},
      );
      // RPC trả về một List<dynamic>, cần ép kiểu
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      print('Lỗi khi lấy danh sách điểm danh: $e');
      return [];
    }
  }
}