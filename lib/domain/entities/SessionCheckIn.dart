class SessionCheckIn {
  final int checkinId;
  final int sessionId;
  final int studentId;
  final DateTime checkinTime;
  final String method; // QR / manual

  SessionCheckIn({
    required this.checkinId,
    required this.sessionId,
    required this.studentId,
    required this.checkinTime,
    required this.method,
  });
}