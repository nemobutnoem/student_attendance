import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/student_in_event_model.dart';

// Đảm bảo file này chỉ chứa class StudentInEventService
class StudentInEventService {
  SupabaseClient get _supabase => Supabase.instance.client;
  static const String _tableName = 'student_in_event';
  static const String _idColumn = 'id';

  /// Lấy TẤT CẢ các lượt đăng ký của sinh viên trong tất cả sự kiện.
  // Future<List<StudentInEvent>> fetchAllStudentRegistrations() async {
  //   try {
  //     // Dùng .select() mà không có bộ lọc để lấy tất cả bản ghi
  //     final data = await _supabase.from(_tableName).select();
  //     return data.map((item) => StudentInEvent.fromJson(item)).toList();
  //   } catch (e) {
  //     print('Lỗi khi lấy tất cả lượt đăng ký: $e');
  //     throw Exception('Không thể tải danh sách tổng hợp.');
  //   }
  // }

  /// Lấy danh sách sinh viên đã đăng ký trong một sự kiện cụ thể.
  Future<List<StudentInEvent>> fetchStudentsInEvent(int eventId) async {
    try {
      final data = await _supabase
          .from(_tableName)
          .select('id, status, event_id, student_id, student!inner(student_id, name, email)')
          .eq('event_id', eventId);
      print('🔥 Raw data từ Supabase: $data');
      return data.map((item) => StudentInEvent.fromJson(item)).toList();
    } catch (e) {
      print('Lỗi khi lấy danh sách sinh viên: $e');
      throw Exception('Không thể tải danh sách sinh viên.');
    }
  }



  /// Cập nhật trạng thái của một sinh viên trong sự kiện (ví dụ: 'attended', 'cancelled').
  Future<void> updateStudentStatus(int? studentInEventId, String newStatus) async {
    if (studentInEventId == null) {
      throw Exception('ID bản ghi không hợp lệ để cập nhật.');
    }
    try {
      await _supabase
          .from(_tableName)
          .update({'status': newStatus})
          .eq(_idColumn, studentInEventId);
    } catch (e) {
      print('Lỗi khi cập nhật trạng thái: $e');
      throw Exception('Không thể cập nhật trạng thái.');
    }
  }

  /// Thêm một sinh viên vào sự kiện.
  Future<Map<String, dynamic>?> addStudentToEvent(int eventId, int studentId) async {
    try {
      final data = await _supabase
          .from(_tableName) // student_in_event
          .insert({
        'event_id': eventId,
        'student_id': studentId,
        'status': 'registered',
      })
          .select('id, student_id, status, event:event_id (id, title, start_date, end_date)')
          .single();

      return data;
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw Exception("Sinh viên này đã đăng ký sự kiện.");
      }
      print('Lỗi Postgres khi thêm sinh viên: ${e.message}');
      throw Exception("Không thể thêm sinh viên vào sự kiện.");
    } catch (e) {
      print('Lỗi khác khi thêm sinh viên: $e');
      throw Exception("Không thể thêm sinh vQiên vào sự kiện.");
    }
  }





  /// Xóa một sinh viên khỏi sự kiện.
  Future<void> deleteStudentFromEvent(int? studentInEventId) async {
    if (studentInEventId == null) {
      throw Exception('ID bản ghi không hợp lệ để xóa.');
    }
    try {
      await _supabase
          .from(_tableName)
          .delete()
          .eq(_idColumn, studentInEventId);
    } catch (e) {
      print('Lỗi khi xóa sinh viên khỏi sự kiện: $e');
      throw Exception('Không thể xóa sinh viên.');
    }
  }

  /// Import danh sách sinh viên vào sự kiện
  Future<void> importStudentsToEvent(int eventId, List<int> studentIds) async {
    final rows = studentIds.map((id) => {
      'event_id': eventId,
      'student_id': id,
      'status': 'registered',
    }).toList();

    await _supabase.from(_tableName).insert(rows);
  }

  /// Lấy danh sách sự kiện còn hạn (end_date >= NOW)
  Future<List<Map<String, dynamic>>> fetchActiveEvents() async {
    try {
      final data = await _supabase
          .from('event')
          .select('event_id, title, start_date, end_date')
          .gte('end_date', DateTime.now().toUtc().toIso8601String());

      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print("Lỗi khi lấy sự kiện: $e");
      rethrow;
    }
  }


}