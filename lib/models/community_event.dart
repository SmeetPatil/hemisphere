class CommunityEvent {
  final String id;
  final String title;
  final String description;
  final String organizer;
  final DateTime dateTime;
  final String location;
  final String category;
  final int attendees;
  final int maxAttendees;
  final String? imageUrl;

  const CommunityEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.organizer,
    required this.dateTime,
    required this.location,
    required this.category,
    required this.attendees,
    required this.maxAttendees,
    this.imageUrl,
  });

  bool get isFull => attendees >= maxAttendees;
  double get fillPercentage => attendees / maxAttendees;
}
