// models/event_model.dart
class AgricultureEvent {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String location;
  final String imageUrl;
  final String organizer;

  AgricultureEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    this.imageUrl = '',
    required this.organizer,
  });
}
