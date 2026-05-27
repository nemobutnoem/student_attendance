import 'package:supabase_flutter/supabase_flutter.dart';

class SessionCheckInService {
  final supabase = Supabase.instance.client;

  Future<bool> createCheckin({
    required int sessionId,
    required int studentId,
    required String method,
  }) async {
    try {
      // 1. Check if student is already checked in for this session
      final existingCheckin = await supabase
          .from('session_checkin')
          .select('checkin_id')
          .eq('session_id', sessionId)
          .eq('student_id', studentId)
          .maybeSingle();

      if (existingCheckin != null) {
        print('Student already checked in for this session');
        return false; // Student already checked in
      }

      // 2. Lấy user_id từ bảng student dựa vào studentId
      final student = await supabase
          .from('student')
          .select('user_id')
          .eq('student_id', studentId)
          .single();

      final userId = student['user_id'];
      if (userId == null) {
        print('Check-in error: user_id của sinh viên không tồn tại!');
        return false;
      }

      // 3. Thực hiện insert check-in với user_id lấy được
      final response = await supabase.from('session_checkin').insert({
        'session_id': sessionId,
        'student_id': studentId,
        'user_id': userId,
        'method': method,
      });

      print('DEBUG Insert response: $response');
      return true;
    } catch (e) {
      print('Check-in error: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getCheckinStatusForSession(int sessionId) async {
    try {
      // Clear any cache and force fresh data
      final response = await supabase
          .rpc(
        'get_checkin_status_for_session',
        params: {'session_id': sessionId},
      )
          .select(); // Force fresh data

      print('DEBUG: Raw response from database: $response');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Lỗi khi lấy danh sách điểm danh: $e');
      return [];
    }
  }

}
