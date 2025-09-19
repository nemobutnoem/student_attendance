import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/event_model.dart';

class ApiService {
  // SỬA Ở ĐÂY: Xóa dòng `final SupabaseClient _supabase = Supabase.instance.client;`

  // Thay vào đó, tạo một getter để lấy client một cách an toàn
  SupabaseClient get _supabase => Supabase.instance.client;

  static const String _tableName = 'event';
  static const String _idColumn = 'event_id';

  Future<List<Event>> fetchEvents() async {
    print('Đang lấy dữ liệu từ Supabase, bảng: $_tableName');
    try {
      final List<dynamic> data = await _supabase // <-- Dùng getter
          .from(_tableName)
          .select()
          .order('start_date', ascending: false);

      List<Event> events = data.map((dynamic item) => Event.fromJson(item)).toList();
      print('Lấy dữ liệu Supabase thành công, số sự kiện: ${events.length}');
      return events;
    } catch (e) {
      print('Đã xảy ra lỗi khi lấy dữ liệu Supabase: $e');
      throw Exception('Lỗi khi tải dữ liệu sự kiện từ Supabase.');
    }
  }

  Future<Event> createEvent(Event event) async {
    print('Đang tạo sự kiện mới trên Supabase, bảng: $_tableName');
    try {
      final List<dynamic> response = await _supabase // <-- Dùng getter
          .from(_tableName)
          .insert(event.toJson())
          .select();

      print('Tạo sự kiện trên Supabase thành công!');
      return Event.fromJson(response.first);
    } catch (e) {
      print('Lỗi khi tạo sự kiện trên Supabase: $e');
      throw Exception('Lỗi khi tạo sự kiện.');
    }
  }

  Future<Event> updateEvent(Event event) async {
    if (event.id == null) {
      throw Exception('Không thể cập nhật sự kiện vì thiếu ID.');
    }
    print('Đang cập nhật sự kiện trên Supabase, ID: ${event.id}');
    try {
      final List<dynamic> response = await _supabase // <-- Dùng getter
          .from(_tableName)
          .update(event.toJson())
          .eq(_idColumn, event.id!)
          .select();

      if (response.isEmpty) {
        throw Exception('Không tìm thấy sự kiện với ID ${event.id} để cập nhật.');
      }
      print('Cập nhật sự kiện trên Supabase thành công!');
      return Event.fromJson(response.first);
    } catch (e) {
      print('Lỗi khi cập nhật sự kiện trên Supabase: $e');
      throw Exception('Lỗi khi cập nhật sự kiện.');
    }
  }

  Future<void> deleteEvent(int? eventId) async {
    if (eventId == null) {
      throw Exception('ID của sự kiện không được null khi xóa.');
    }
    print('Đang xóa sự kiện trên Supabase, ID: $eventId');
    try {
      await _supabase // <-- Dùng getter
          .from(_tableName)
          .delete()
          .eq(_idColumn, eventId);

      print('Xóa sự kiện trên Supabase thành công!');
    } catch (e) {
      print('Lỗi khi xóa sự kiện trên Supabase: $e');
      throw Exception('Lỗi khi xóa sự kiện.');
    }
  }
}