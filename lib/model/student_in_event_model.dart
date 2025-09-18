class StudentInEvent {
  // 1. Sửa kiểu dữ liệu của các ID thành int
  final int? id; // Khóa chính, có thể null khi tạo mới
  final int eventId;
  final int studentId;
  final String status; // registered / cancelled / attended

  StudentInEvent({
    this.id, // Cho phép id là null
    required this.eventId,
    required this.studentId,
    required this.status,
  });

  // ==========================================================
  // SỬA LẠI HÀM fromJson
  // ==========================================================
  factory StudentInEvent.fromJson(Map<String, dynamic> json) {
    return StudentInEvent(
      // 2. Đọc đúng tên cột và kiểu dữ liệu
      id: json['id'],
      eventId: json['event_id'],
      studentId: json['student_id'],
      status: json['status'],
    );
  }

  // ==========================================================
  // SỬA LẠI HÀM toJson
  // ==========================================================
  Map<String, dynamic> toJson() {
    // 3. Chỉ gửi các trường dữ liệu, không gửi khóa chính 'id'
    return {
      'event_id': eventId,
      'student_id': studentId,
      'status': status,
    };
  }
}