enum ResourceCategory { tools, skills, hobbies, books, sports, other }

class ResourceListing {
  final String id;
  final String title;
  final String description;
  final String ownerName;
  final String ownerAvatar;
  final ResourceCategory category;
  final bool isAvailable;
  final DateTime postedAt;

  const ResourceListing({
    required this.id,
    required this.title,
    required this.description,
    required this.ownerName,
    required this.ownerAvatar,
    required this.category,
    required this.isAvailable,
    required this.postedAt,
  });

  String get categoryLabel {
    switch (category) {
      case ResourceCategory.tools:
        return 'Tools';
      case ResourceCategory.skills:
        return 'Skills';
      case ResourceCategory.hobbies:
        return 'Hobbies';
      case ResourceCategory.books:
        return 'Books';
      case ResourceCategory.sports:
        return 'Sports';
      case ResourceCategory.other:
        return 'Other';
    }
  }
}
