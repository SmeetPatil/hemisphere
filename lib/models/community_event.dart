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
  final String? neighborhoodId;
  final double? latitude;
  final double? longitude;
  final String? createdBy;
  final List<String>? joinedBy;

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
    this.neighborhoodId,
    this.latitude,
    this.longitude,
    this.createdBy,
    this.joinedBy,
  });

  bool get isFull => attendees >= maxAttendees;
  double get fillPercentage => attendees / maxAttendees;
}
