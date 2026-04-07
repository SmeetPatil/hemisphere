import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';

class MyActivityList extends StatefulWidget {
  const MyActivityList({super.key});

  @override
  State<MyActivityList> createState() => _MyActivityListState();
}

class _MyActivityListState extends State<MyActivityList> {
  bool _loading = true;
  List<_ActivityItem> _activities = [];

  @override
  void initState() {
    super.initState();
    _loadActivity();
  }

  Future<void> _loadActivity() async {
    setState(() => _loading = true);
    final List<_ActivityItem> items = [];
    final db = FirestoreService.instance;

    // Fetch Events
    final eventsRef = await db.getUserEvents();
    for (var doc in eventsRef) {
      items.add(_ActivityItem(
        id: doc.id,
        title: doc.title,
        description: doc.description,
        type: 'Event',
        date: doc.dateTime,
        onDelete: () => _deleteItem(doc.id, 'event'),
      ));
    }

    // Fetch Resources
    final resourcesRef = await db.getUserResources();
    for (var doc in resourcesRef) {
      items.add(_ActivityItem(
        id: doc.id,
        title: doc.title,
        description: doc.description,
        type: doc.category.name.toLowerCase() == 'hobbies' ? 'Hobby' : 'Resource',
        date: doc.postedAt,
        onDelete: () => _deleteItem(doc.id, 'resource', isHobby: doc.category.name.toLowerCase() == 'hobbies'),
      ));
    }

    // Fetch Feed/Reports
    final feedRef = await db.getUserFeedPosts();
    for (var doc in feedRef) {
      items.add(_ActivityItem(
        id: doc.id,
        title: 'Report: ${doc.type}',
        description: doc.content,
        type: 'Report',
        date: doc.timestamp,
        onDelete: () => _deleteItem(doc.id, 'feed'),
      ));
    }

    items.sort((a, b) => b.date.compareTo(a.date));

    if (mounted) {
      setState(() {
        _activities = items;
        _loading = false;
      });
    }
  }

  Future<void> _deleteItem(String id, String colType, {bool isHobby = false}) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.h.surface,
        title: Text('Delete Post', style: TextStyle(color: context.h.textPrimary)),
        content: Text('Are you sure you want to delete this?', style: TextStyle(color: context.h.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true), 
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirestoreService.instance.deleteUserPost(id, colType, isHobby: isHobby);
      _loadActivity(); // Reload
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_activities.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'No recent activity.',
            style: AppTextStyles.bodyLarge.copyWith(color: context.h.textSecondary),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _activities.length,
      itemBuilder: (context, index) {
        final item = _activities[index];
        final colors = context.h;
        return Card(
          color: colors.card,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(item.title, style: AppTextStyles.headlineSmall.copyWith(color: colors.textPrimary, fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(item.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTextStyles.bodyMedium.copyWith(color: colors.textSecondary)),
                const SizedBox(height: 8),
                Text(
                  '${item.type} • ${item.date.month}/${item.date.day}/${item.date.year}',
                  style: AppTextStyles.bodySmall.copyWith(color: colors.textSecondary),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: item.onDelete,
            ),
          ),
        );
      },
    );
  }
}

class _ActivityItem {
  final String id;
  final String title;
  final String description;
  final String type;
  final DateTime date;
  final VoidCallback onDelete;

  _ActivityItem({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.date,
    required this.onDelete,
  });
}
