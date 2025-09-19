class SessionCheckIn {
  final int checkinId;
  final int sessionId;
  // SỬA 1: Đổi từ String sang int để khớp với database
  final int studentId;
  final DateTime checkinTime;
  // SỬA 2: Thêm trường method
  final String method;

  SessionCheckIn({
    required this.checkinId,
    required this.sessionId,
    required this.studentId,
    required this.checkinTime,
    required this.method, // Thêm vào constructor
  });

  // Factory constructor để parse dữ liệu JSON từ server
  factory SessionCheckIn.fromJson(Map<String, dynamic> json) {
    return SessionCheckIn(
      checkinId: json['checkin_id'],
      sessionId: json['session_id'],
      studentId: json['student_id'], // JSON trả về vẫn là số
      checkinTime: DateTime.parse(json['checkin_time']),
      method: json['method'], // Thêm vào fromJson
    );
  }

  // Hàm để chuyển đổi object thành JSON (khi gửi lên server)
  // Lưu ý: Chúng ta thường không cần gửi checkin_id và checkin_time khi TẠO MỚI.
  // Hàm này hữu ích cho việc cập nhật hoặc các mục đích khác.
  Map<String, dynamic> toJson() {
    return {
      'checkin_id': checkinId,
      'session_id': sessionId,
      'student_id': studentId,
      'checkin_time': checkinTime.toIso8601String(),
      'method': method, // Thêm vào toJson
    };
  }
}