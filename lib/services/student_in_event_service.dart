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
  Future<List<StudentInEvent>> fetchAllStudentsInEvents() async {
    try {
      final data = await _supabase
          .from(_tableName)
          .select('''
          id, status, event_id, student_id,
          students(student_id, student_code, name, email),
          event(event_id, title)
        ''');

      print('🔥 Raw data tất cả sự kiện: $data');
      return data.map<StudentInEvent>((item) => StudentInEvent.fromJson(item)).toList();
    } catch (e) {
      print('Lỗi khi lấy tất cả sinh viên trong các sự kiện: $e');
      throw Exception('Không thể tải danh sách sinh viên trong các sự kiện.');
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
  Future<StudentInEvent?> addStudentToEvent(int eventId, String studentCode) async {
    try {
      // 1. Tìm student_id theo student_code
      final studentData = await _supabase
          .from('students')
          .select('student_id')
          .eq('student_code', studentCode)
          .maybeSingle();

      if (studentData == null) {
        throw Exception("Không tìm thấy sinh viên với mã: $studentCode");
      }

      final studentId = studentData['student_id'];

      // 2. Insert student vào event
      final data = await _supabase
          .from(_tableName)
          .insert({
        'event_id': eventId,
        'student_id': studentId,
        'status': 'registered',
      })
          .select('''
          id, student_id, status,
          students(student_id, student_code, name, email),
          event(event_id, title)
        ''')
          .single();

      print("🔥 Insert result: $data");

      // 3. (Optional) Fetch lại list để debug
      final updatedList = await fetchAllStudentsInEvents();
      print("✅ Danh sách sau insert: $updatedList");

      return StudentInEvent.fromJson(data);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw Exception("Sinh viên này đã đăng ký sự kiện.");
      }
      print('Lỗi Postgres khi thêm sinh viên: ${e.message}');
      throw Exception("Không thể thêm sinh viên vào sự kiện.");
    } catch (e) {
      print('Lỗi khác khi thêm sinh viên: $e');
      throw Exception("Không thể thêm sinh viên vào sự kiện.");
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
    try {
      final rows = studentIds.map((sid) => {
        'event_id': eventId,
        'student_id': sid,
        'status': 'registered',
      }).toList();

      final response = await _supabase
          .from('student_in_event')
          .insert(rows);

      print('✅ Import thành công: $response');
    } catch (e) {
      print('❌ Lỗi import sinh viên: $e');
      throw Exception('Không thể import sinh viên vào sự kiện.');
    }
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