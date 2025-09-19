import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/event_model.dart';

class ApiService {
  final supabase = Supabase.instance.client;

  Future<List<Event>> fetchEvents() async {
    try {
      // SỬA: Dùng đúng tên bảng 'event' và sắp xếp theo 'start_date'
      final response = await supabase.from('event').select().order('start_date', ascending: false);
      final List<Event> events = (response as List).map((data) => Event.fromJson(data)).toList();
      return events;
    } catch (e) {
      print('Lỗi khi tải sự kiện: $e');
      throw Exception('Không thể tải danh sách sự kiện.');
    }
  }

  Future<List<Map<String, dynamic>>> fetchStudentDataForEvent(int eventId) async {
    try {
      // SỬA: Truy vấn đúng theo schema của bạn
      final response = await supabase
          .from('student_in_event') // Sửa tên bảng
          .select('*, students(*, university(*))')
          .eq('event_id', eventId);
      return response as List<Map<String, dynamic>>;
    } catch (e) {
      print('Lỗi khi tải dữ liệu sinh viên: $e');
      throw Exception('Không thể tải dữ liệu sinh viên cho sự kiện.');
    }
  }

  Future<List<Map<String, dynamic>>> fetchAllAttendanceForStats() async {
    try {
      // SỬA: Truy vấn thống kê đúng theo schema của bạn
      final response = await supabase
          .from('student_in_event') // Sửa tên bảng
          .select('''
            event ( event_id, title, start_date ),
            students ( student_id, name, student_code, university ( university_id, name ) )
          ''');

      return response as List<Map<String, dynamic>>;
    } catch (e) {
      print('LỖI THỐNG KÊ CHI TIẾT: $e');
      throw Exception('Không thể tải dữ liệu thống kê. Vui lòng kiểm tra lại quyền truy cập (RLS) trên Supabase.');
    }
  }

  Future<void> createEvent(Event event) async {
    try {
      // SỬA: Dùng đúng tên bảng 'event'
      await supabase.from('event').insert(event.toJson());
    } catch (e) {
      print('Lỗi khi tạo sự kiện: $e');
      throw Exception('Tạo sự kiện thất bại.');
    }
  }

  Future<void> updateEvent(Event event) async {
    if (event.id == null) {
      throw Exception('Không thể cập nhật sự kiện không có ID.');
    }
    try {
      // SỬA: Dùng đúng tên bảng 'event' và khóa chính 'event_id'
      await supabase.from('event').update(event.toJson()).eq('event_id', event.id!);
    } catch (e) {
      print('Lỗi khi cập nhật sự kiện: $e');
      throw Exception('Cập nhật sự kiện thất bại.');
    }
  }

  Future<void> deleteEvent(int eventId) async {
    try {
      // SỬA: Xóa từ các bảng có tên đúng
      await supabase.from('student_in_event').delete().eq('event_id', eventId);
      await supabase.from('event').delete().eq('event_id', eventId);
    } catch (e) {
      print('Lỗi khi xóa sự kiện: $e');
      throw Exception('Xóa sự kiện thất bại.');
    }
  }
}