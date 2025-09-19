import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/event_session_model.dart';

class EventSessionService {
  SupabaseClient get _supabase => Supabase.instance.client;

  static const String _tableName = 'event_session';
  static const String _idColumn = 'session_id';

  Future<List<EventSession>> fetchEventSessions({int? eventId}) async {
    print('Đang lấy dữ liệu phiên sự kiện từ Supabase, bảng: $_tableName');
    try {
      final List<dynamic> data;
      
      if (eventId != null) {
        data = await _supabase
            .from(_tableName)
            .select()
            .eq('event_id', eventId)
            .order('start_time', ascending: true);
      } else {
        data = await _supabase
            .from(_tableName)
            .select()
            .order('start_time', ascending: true);
      }

      List<EventSession> sessions = data.map((dynamic item) => EventSession.fromJson(item)).toList();
      print('Lấy dữ liệu phiên sự kiện thành công, số phiên: ${sessions.length}');
      return sessions;
    } catch (e) {
      print('Đã xảy ra lỗi khi lấy dữ liệu phiên sự kiện: $e');
      throw Exception('Lỗi khi tải dữ liệu phiên sự kiện từ Supabase.');
    }
  }

  Future<EventSession> createEventSession(EventSession session) async {
    print('Đang tạo phiên sự kiện mới trên Supabase, bảng: $_tableName');
    try {
      final List<dynamic> response = await _supabase
          .from(_tableName)
          .insert(session.toJson())
          .select();

      print('Tạo phiên sự kiện trên Supabase thành công!');
      return EventSession.fromJson(response.first);
    } catch (e) {
      print('Lỗi khi tạo phiên sự kiện trên Supabase: $e');
      throw Exception('Lỗi khi tạo phiên sự kiện.');
    }
  }

  Future<EventSession> updateEventSession(EventSession session) async {
    if (session.sessionId == null) {
      throw Exception('Không thể cập nhật phiên sự kiện vì thiếu ID.');
    }
    print('Đang cập nhật phiên sự kiện trên Supabase, ID: ${session.sessionId}');

    try {
      final List<dynamic> response = await _supabase
          .from(_tableName)
          .update(session.toJson())
          .eq(_idColumn, session.sessionId!)
          .select();

      print('Cập nhật phiên sự kiện trên Supabase thành công!');
      return EventSession.fromJson(response.first);
    } catch (e) {
      print('Lỗi khi cập nhật phiên sự kiện trên Supabase: $e');
      throw Exception('Lỗi khi cập nhật phiên sự kiện.');
    }
  }

  Future<void> deleteEventSession(int? sessionId) async {
    if (sessionId == null) {
      throw Exception('Không thể xóa phiên sự kiện vì thiếu ID.');
    }
    print('Đang xóa phiên sự kiện trên Supabase, ID: $sessionId');

    try {
      await _supabase
          .from(_tableName)
          .delete()
          .eq(_idColumn, sessionId);

      print('Xóa phiên sự kiện trên Supabase thành công!');
    } catch (e) {
      print('Lỗi khi xóa phiên sự kiện trên Supabase: $e');
      throw Exception('Lỗi khi xóa phiên sự kiện.');
    }
  }

  Future<EventSession?> getEventSessionById(int sessionId) async {
    print('Đang lấy phiên sự kiện theo ID từ Supabase, ID: $sessionId');
    try {
      final List<dynamic> data = await _supabase
          .from(_tableName)
          .select()
          .eq(_idColumn, sessionId);

      if (data.isNotEmpty) {
        EventSession session = EventSession.fromJson(data.first);
        print('Lấy phiên sự kiện theo ID thành công!');
        return session;
      } else {
        print('Không tìm thấy phiên sự kiện với ID: $sessionId');
        return null;
      }
    } catch (e) {
      print('Lỗi khi lấy phiên sự kiện theo ID: $e');
      throw Exception('Lỗi khi tải phiên sự kiện.');
    }
  }
}