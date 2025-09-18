class Event {
  // Thay đổi id từ int? thành dynamic để linh hoạt hơn
  final dynamic id;
  final String title;
  final String description;
  final String organizer;
  final DateTime startDate;
  final DateTime endDate;

  Event({
    this.id,
    required this.title,
    required this.description,
    required this.organizer,
    required this.startDate,
    required this.endDate,
  });

  // ==========================================================
  // SỬA LẠI HÀM NÀY
  // ==========================================================
  factory Event.fromJson(Map<String, dynamic> json) {
    // Thêm logic để xử lý id một cách an toàn
    dynamic eventId = json['event_id'] ?? json['id'];

    return Event(
      id: eventId, // Gán id đã được xử lý
      title: json['title'],
      description: json['description'],
      organizer: json['organizer'],
      // Dùng fromJson, MockAPI thường trả về chuỗi ISO 8601
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
    );
  }

  // ==========================================================
  // SỬA LẠI HÀM NÀY
  // ==========================================================
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'title': title,
      'description': description,
      'organizer': organizer,
      // Định dạng ngày thành chuỗi YYYY-MM-DD phù hợp cho API
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
    };

    // Rất quan trọng: Chỉ thêm 'id' vào JSON khi chỉnh sửa.
    // Khi tạo mới, id là null và không nên gửi lên server.
    if (id != null) {
      data['event_id'] = id;
    }

    return data;
  }
}