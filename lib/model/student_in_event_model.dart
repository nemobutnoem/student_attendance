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
      id: json['id'] as int,
      status: json['status'] as String,
      eventId: json['event_id'] as int,
      studentId: json['student_id'] as int,
      student: json['student'] != null
          ? Student.fromJson(json['student'])
          : null,
      event: json['event'],

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event_id': eventId,
      'student_id': studentId,
      'status': status,
    };
  }
}


class Student {
  final int studentId;
  final String name;
  final String email;

  Student({
    required this.studentId,
    required this.name,
    required this.email,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      studentId: json['student_id'] as int,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

