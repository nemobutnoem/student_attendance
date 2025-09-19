class StudentInEvent {
  final int? id;
  final int eventId;
  final int studentId;
  final String status;
  final Student? student;
  final Map<String, dynamic>? event;


  StudentInEvent({
    this.id,
    required this.eventId,
    required this.studentId,
    required this.status,
    this.student,
    this.event,
  });

  factory StudentInEvent.fromJson(Map<String, dynamic> json) {
    return StudentInEvent(
      id: json['id'] as int?,
      status: json['status'] as String,
      studentId: json['student_id'] as int,
      eventId: (json['event_idR'] ?? json['event']?['event_id']) as int,
      student: (json['students'] != null && json['students'] is Map<String, dynamic>)
          ? Student.fromJson(json['students'] as Map<String, dynamic>)
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
  final int studentId;
  final String name;
  final String email;
  final String studentCode;


  Student({
    required this.studentId,
    required this.name,
    required this.email,
    required this.studentCode,

  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      studentId: json['student_id'] as int,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      studentCode: json['student_code'] ?? '',
    );
  }
}
