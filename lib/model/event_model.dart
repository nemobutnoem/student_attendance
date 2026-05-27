class Event {
  final int? id;
  // BỔ SUNG: Thêm lại trường userId. Đây là trường bắt buộc để RLS hoạt động.
  final int? userId;
  final String title;
  final String description;
  final String organizer;
  final DateTime startDate;
  final DateTime endDate;

  Event({
    this.id,
    this.userId, // Thêm vào constructor
    required this.title,
    required this.description,
    required this.organizer,
    required this.startDate,
    required this.endDate,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['event_id'],
      userId: json['user_id'], // Đọc user_id từ JSON
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      organizer: json['organizer'] ?? '',
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
    );
  }

// Hàm toJson không cần thiết khi dùng cách tiếp cận này,
// vì chúng ta tạo Map dữ liệu trực tiếp trong màn hình Create/Edit.
// Bạn có thể giữ hoặc xóa nó đi.
}