class StudentInEvent {
  final String id; // student_in_event_id
  final String eventId;
  final String studentId;
  final String status; // registered / cancelled / attended

  StudentInEvent({
    required this.id,
    required this.eventId,
    required this.studentId,
    required this.status,
  });

  factory StudentInEvent.fromJson(Map<String, dynamic> json) {
    return StudentInEvent(
      id: json['student_in_event_id'],
      eventId: json['event_id'],
      studentId: json['student_id'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student_in_event_id': id,
      'event_id': eventId,
      'student_id': studentId,
      'status': status,
    };
  }
}
