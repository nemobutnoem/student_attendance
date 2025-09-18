class StudentInEvent {
  final int studentInEventId;
  final int eventId;
  final int studentId;
  final String status; // registered / cancelled / attended

  StudentInEvent({
    required this.studentInEventId,
    required this.eventId,
    required this.studentId,
    required this.status,
  });
}