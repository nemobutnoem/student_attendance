class Event {
  final int eventId;
  final String title;
  final String description;
  final String organizer;
  final DateTime startDate;
  final DateTime endDate;

  Event({
    required this.eventId,
    required this.title,
    required this.description,
    required this.organizer,
    required this.startDate,
    required this.endDate,
  });
}