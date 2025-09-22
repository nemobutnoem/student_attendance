class StudentInEvent {
  final int? id;
  final int? eventId;
  final int? studentId;
  final String? status;
  final Student? student;
  final Map<String, dynamic>? event;

  StudentInEvent({
    this.id,
    this.eventId,
    this.studentId,
    this.status,
    this.student,
    this.event,
  });

  factory StudentInEvent.fromJson(Map<String, dynamic> json) {
    return StudentInEvent(
      id: json['student_in_event_id'] as int?,
      status: json['status'] as String?,
      studentId: json['student_id'] as int?,
      eventId: json['event_id'] as int?, // ✅ fix
      student: (json['student'] != null && json['student'] is Map<String, dynamic>)
          ? Student.fromJson(json['student'] as Map<String, dynamic>) // ✅ fix
          : null,
      event: (json['event'] != null && json['event'] is Map<String, dynamic>)
          ? json['event'] as Map<String, dynamic>
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event_id': eventId,
      'student_id': studentId,
      'status': status,
    };
  }

  String get eventTitle => event?['title'] ?? 'Không có tên sự kiện';
}

class Student {
  final int? studentId;
  final String? name;
  final String? email;
  final String? studentCode;

  Student({
    this.studentId,
    this.name,
    this.email,
    this.studentCode,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      studentId: json['student_id'] as int?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      studentCode: json['student_code'] as String?, // ✅ map đúng
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'name': name,
      'email': email,
      'student_code': studentCode,
    };
  }
}
