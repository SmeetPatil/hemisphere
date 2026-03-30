enum PostType { update, helpRequest, news, alert }

class FeedPost {
  final String id;
  final String authorName;
  final String authorAvatar;
  final String content;
  final PostType type;
  final DateTime timestamp;
  final int likes;
  final int comments;
  final String? imageUrl;
  final String? location;

  const FeedPost({
    required this.id,
    required this.authorName,
    required this.authorAvatar,
    required this.content,
    required this.type,
    required this.timestamp,
    required this.likes,
    required this.comments,
    this.imageUrl,
    this.location,
  });

  String get typeLabel {
    switch (type) {
      case PostType.update:
        return 'Update';
      case PostType.helpRequest:
        return 'Help Needed';
      case PostType.news:
        return 'News';
      case PostType.alert:
        return 'Alert';
    }
  }
}
