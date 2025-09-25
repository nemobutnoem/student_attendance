import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/event_model.dart';

class ApiService {
  final supabase = Supabase.instance.client;

  /// Lấy danh sách sự kiện dựa trên vai trò của người dùng.
  /// Kết hợp cả logic trong code và RLS trên Supabase để đảm bảo an toàn.
  Future<List<Event>> fetchEvents({required String role, required int userId}) async {
    print('>>> Đang tải sự kiện cho - Role: "$role", UserID: $userId');

    try {
      final query = supabase.from('event').select('*');

      // PHẦN QUAN TRỌNG: Phân quyền rõ ràng trong code
      if (role == 'admin') {
        // Admin có quyền xem tất cả, không cần thêm bộ lọc từ client.
        // RLS trên server sẽ xác nhận quyền này.
      } else if (role == 'organizer') {
        // Organizer chỉ được xem sự kiện có user_id của chính họ.
        query.eq('user_id', userId);
      } else {
        // Các vai trò khác (student, v.v...) không có quyền xem trong màn hình này.
        // Trả về danh sách rỗng ngay lập tức để tránh gọi API không cần thiết.
        return [];
      }

      final response = await query.order('start_date', ascending: false);
      final List<Event> events = (response as List).map((data) => Event.fromJson(data)).toList();
      return events;
    } catch (e) {
      print('Lỗi khi tải sự kiện: $e');
      // Phân tích lỗi từ Supabase để đưa ra thông báo hữu ích
      if (e is PostgrestException && e.code == '42501') {
        throw Exception('Không có quyền truy cập. Vui lòng kiểm tra lại chính sách RLS trên Supabase.');
      }
      throw Exception('Không thể tải danh sách sự kiện.');
    }
  }

  /// Lấy danh sách sinh viên đã đăng ký cho một sự kiện cụ thể.
  Future<List<Map<String, dynamic>>> fetchStudentDataForEvent(int eventId) async {
    try {
      final response = await supabase
          .from('student_in_event')
          .select('*, student(*, university(*))')
          .eq('event_id', eventId);
      return response as List<Map<String, dynamic>>;
    } catch (e) {
      print('Lỗi khi tải dữ liệu sinh viên: $e');
      throw Exception('Không thể tải dữ liệu sinh viên cho sự kiện.');
    }
  }

  /// Lấy toàn bộ dữ liệu điểm danh để làm thống kê.
  Future<List<Map<String, dynamic>>> fetchAllAttendanceForStats() async {
    try {
      // Sửa lỗi chính tả: event(id -> event(event_id
      final response = await supabase
          .from('student_in_event')
          .select('''
            event( event_id, title, start_date ),
            student( student_id, name, student_code, university( university_id, name ) )
          ''');
      return response as List<Map<String, dynamic>>;
    } catch (e) {
      print('LỖI THỐNG KÊ CHI TIẾT: $e');
      throw Exception('Không thể tải dữ liệu thống kê.');
    }
  }

  /// Tạo một sự kiện mới.
  Future<void> createEvent(Map<String, dynamic> eventData) async {
    try {
      await supabase.from('event').insert(eventData);
    } catch (e) {
      print('Lỗi khi tạo sự kiện: $e');
      throw Exception('Tạo sự kiện thất bại.');
    }
  }

  /// Cập nhật thông tin một sự kiện.
  Future<void> updateEvent(int eventId, Map<String, dynamic> eventData) async {
    try {
      // SỬA: Dùng 'event_id' là khóa chính thay vì 'id'
      await supabase.from('event').update(eventData).eq('event_id', eventId);
    } catch (e) {
      print('Lỗi khi cập nhật sự kiện: $e');
      throw Exception('Cập nhật sự kiện thất bại.');
    }
  }

  /// Xóa một sự kiện và các dữ liệu liên quan.
  Future<void> deleteEvent(int eventId) async {
    try {
      // 1. Xóa các bản ghi ghi danh của sinh viên trong sự kiện đó trước.
      await supabase.from('student_in_event').delete().eq('event_id', eventId);

      // 2. Sau đó mới xóa sự kiện chính.
      // SỬA: Dùng 'event_id' là khóa chính thay vì 'id'
      await supabase.from('event').delete().eq('event_id', eventId);
    } catch (e) {
      print('Lỗi khi xóa sự kiện: $e');
      throw Exception('Xóa sự kiện thất bại.');
    }
  }
}