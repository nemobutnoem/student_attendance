class EventSession {
  final int sessionId;
  final int eventId;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String location;

  EventSession({
    required this.sessionId,
    required this.eventId,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.location,
  });
}