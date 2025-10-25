class EventSession {
  final int? sessionId;
  final int eventId;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String location;

  EventSession({
    this.sessionId,
    required this.eventId,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.location,
  });

  factory EventSession.fromJson(Map<String, dynamic> json) {
    return EventSession(
      sessionId: json['session_id'],
      eventId: json['event_id'],
      title: json['title'],
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'event_id': eventId,
      'title': title,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'location': location,
    };

    return data;
  }

  Map<String, dynamic> toJsonWithId() {
    final Map<String, dynamic> data = toJson();
    if (sessionId != null) {
      data['session_id'] = sessionId;
    }
    return data;
  }
}