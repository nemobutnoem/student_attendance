import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/event_model.dart';

class ApiService {
  final supabase = Supabase.instance.client;

  // =======================================================================
  // THÊM HÀM MỚI ĐỂ LẤY DANH SÁCH ORGANIZER
  // =======================================================================
  /// Lấy danh sách người dùng có vai trò là 'organizer' cùng với email.
  Future<List<Map<String, dynamic>>> fetchOrganizers() async {
    try {
      // SỬA LỖI: Gọi đúng hàm RPC 'get_organizers' đã được cập nhật
      final response = await supabase.rpc('get_organizers');

      // Dữ liệu trả về từ RPC đã đúng định dạng, không cần xử lý thêm.
      return List<Map<String, dynamic>>.from(response);

    } catch (e) {
      print('Lỗi khi tải danh sách organizers: $e');
      // Thêm thông tin lỗi chi tiết hơn
      if (e is PostgrestException) {
        throw Exception('Lỗi server khi tải organizers: ${e.message}');
      }
      throw Exception('Không thể tải danh sách người phụ trách.');
    }
  }
  // =======================================================================


  /// Lấy danh sách sự kiện dựa trên vai trò của người dùng.
  Future<List<Event>> fetchEvents({required String role, required int userId}) async {
    print('>>> Đang tải sự kiện cho - Role: "$role", UserID: $userId');

    try {
      // SỬA LỖI: Quay trở lại câu lệnh select đơn giản và đáng tin cậy.
      // Chúng ta sẽ không lấy email ở danh sách này để tránh lỗi join phức tạp.
      // Việc join sẽ được thực hiện ở các màn hình chi tiết nếu cần.
      final query = supabase.from('event').select('*');

      // Logic phân quyền không đổi, vẫn giữ nguyên
      if (role == 'organizer') {
        query.eq('user_id', userId);
      } else if (role != 'admin') {
        return [];
      }

      final response = await query.order('start_date', ascending: false);
      final List<Event> events = (response as List).map((data) => Event.fromJson(data)).toList();
      return events;

    } catch (e) {
      print('Lỗi khi tải sự kiện: $e');
      if (e is PostgrestException) {
        // In ra thông báo lỗi chi tiết hơn từ Supabase
        print('Postgrest Error: ${e.message} (Code: ${e.code})');
        throw Exception('Lỗi từ server: ${e.message}');
      }
      throw Exception('Không thể tải danh sách sự kiện. Vui lòng kiểm tra kết nối mạng.');
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
      // SỬA LỖI: Đảm bảo rằng chúng ta đang so sánh (eq) với đúng
      // cột khóa chính là 'event_id' theo schema.
      await supabase.from('event').update(eventData).eq('event_id', eventId);

    } catch (e) {
      // In ra lỗi chi tiết để dễ dàng gỡ rối nếu vấn đề vẫn tiếp diễn
      print('LỖI KHI CẬP NHẬT SỰ KIỆN: $e');
      if (e is PostgrestException) {
        print('Thông báo từ server: ${e.message}');
        print('Chi tiết lỗi: ${e.details}');
        throw Exception('Lỗi từ server: ${e.message}');
      }
      throw Exception('Cập nhật sự kiện thất bại.');
    }
  }

  /// Xóa một sự kiện và các dữ liệu liên quan.
  Future<void> deleteEvent(int eventId) async {
    try {
      // Để đảm bảo an toàn, nên gọi RPC function trên Supabase để xóa
      // thay vì xóa từng bảng từ client. Tuy nhiên, cách này vẫn hoạt động.
      await supabase.from('student_in_event').delete().eq('event_id', eventId);
      await supabase.from('event_session').delete().eq('event_id', eventId); // Thêm xóa session
      await supabase.from('event').delete().eq('event_id', eventId);
    } catch (e) {
      print('Lỗi khi xóa sự kiện: $e');
      throw Exception('Xóa sự kiện thất bại.');
    }
  }
}