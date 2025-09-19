class Event {
  // 1. Sửa id thành int? cho an toàn kiểu và khớp với Supabase (int8)
  final int? id;
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
  // SỬA LẠI HÀM fromJson
  // ==========================================================
  factory Event.fromJson(Map<String, dynamic> json) {
    // Supabase sẽ trả về JSON với key là tên cột, tức là 'event_id'
    return Event(
      id: json['event_id'], // Lấy trực tiếp từ 'event_id'
      title: json['title'],
      description: json['description'],
      organizer: json['organizer'],
      // Supabase trả về chuỗi ISO 8601 cho kiểu 'timestamp', DateTime.parse là chính xác
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
    );
  }

  // ==========================================================
  // SỬA LẠI HÀM toJson
  // ==========================================================
  Map<String, dynamic> toJson() {
    // Hàm này chỉ cần tạo ra một Map chứa các dữ liệu sẽ được insert/update.
    // Không bao giờ cần gửi 'id' trong này khi làm việc với Supabase.
    final Map<String, dynamic> data = {
      'title': title,
      'description': description,
      'organizer': organizer,
      // toIso8601String() là định dạng chuẩn mà Supabase hiểu cho kiểu 'timestamp'
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
    };

    return data;
  }
}