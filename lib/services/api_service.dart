import 'dart:convert';
import 'package:http/http.dart' as http;
// Chỉ import 1 lần
import '../model/event_model.dart';
import '../util/constants.dart';

class ApiService {

  // ==========================================================
  // HÀM LẤY DANH SÁCH SỰ KIỆN (ĐÃ CÓ ĐẦY ĐỦ CODE)
  // ==========================================================
  Future<List<Event>> fetchEvents() async {
    final url = Uri.parse(ApiConstants.baseUrl + ApiConstants.eventEndpoint);
    print('Đang gọi API tại: $url');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        List<Event> events = body.map(
              (dynamic item) => Event.fromJson(item),
        ).toList();

        print('Lấy dữ liệu thành công, số sự kiện: ${events.length}');
        return events;
      } else {
        print('Lỗi API: Status code ${response.statusCode}');
        throw Exception('Lỗi khi tải dữ liệu sự kiện từ server');
      }
    } catch (e) {
      print('Đã xảy ra lỗi: $e');
      throw Exception('Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.');
    }
  }

  // ==========================================================
  // HÀM TẠO SỰ KIỆN
  // ==========================================================
  Future<Event> createEvent(Event event) async {
    final url = Uri.parse(ApiConstants.baseUrl + ApiConstants.eventEndpoint);
    print('Đang gọi API (POST) tại: $url');

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(event.toJson()),
    );

    if (response.statusCode == 201) {
      print('Tạo sự kiện thành công!');
      return Event.fromJson(jsonDecode(response.body));
    } else {
      print('Lỗi API (POST): Status code ${response.statusCode}');
      throw Exception('Lỗi khi tạo sự kiện.');
    }
  }

  // ==========================================================
  // HÀM CẬP NHẬT SỰ KIỆN
  // ==========================================================
  Future<Event> updateEvent(Event event) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.eventEndpoint}/${event.id}');
    print('Đang gọi API (PUT) tại: $url');

    final response = await http.put(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(event.toJson()),
    );

    if (response.statusCode == 200) {
      print('Cập nhật sự kiện thành công!');
      return Event.fromJson(jsonDecode(response.body));
    } else {
      print('Lỗi API (PUT): Status code ${response.statusCode}');
      throw Exception('Lỗi khi cập nhật sự kiện.');
    }
  }
  Future<void> deleteEvent(dynamic eventId) async {
    // URL cho DELETE cũng cần id của sự kiện: /event/{id}
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.eventEndpoint}/$eventId');
    print('Đang gọi API (DELETE) tại: $url');

    final response = await http.delete(url);

    // Mã 200 (OK) hoặc 204 (No Content) đều là thành công cho DELETE
    if (response.statusCode == 200 || response.statusCode == 204) {
      print('Xóa sự kiện thành công!');
    } else {
      print('Lỗi API (DELETE): Status code ${response.statusCode}');
      throw Exception('Lỗi khi xóa sự kiện.');
    }
  }
}