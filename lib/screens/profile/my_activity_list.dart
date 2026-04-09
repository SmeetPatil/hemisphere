import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../home_screen.dart'; // To listen to tab switches

class MyActivityList extends StatefulWidget {
  final int refreshTrigger;
  const MyActivityList({super.key, this.refreshTrigger = 0});

  @override
  State<MyActivityList> createState() => _MyActivityListState();
}

class _MyActivityListState extends State<MyActivityList> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _loading = true;
  List<_ActivityItem> _posts = [];
  List<_ActivityItem> _activities = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
    HomeScreen.currentTabNotifier.addListener(_handleBottomTabSelection);
    _loadData();
  }

  void _handleBottomTabSelection() {
    if (HomeScreen.currentTabNotifier.value == 4) {
      _loadData();
    }
  }

  @override
  void didUpdateWidget(covariant MyActivityList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.refreshTrigger != oldWidget.refreshTrigger) {
      _loadData();
    }
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) return;
    _loadData();
  }

  @override
  void dispose() {
    HomeScreen.currentTabNotifier.removeListener(_handleBottomTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    final db = FirestoreService.instance;
    final List<_ActivityItem> newPosts = [];
    final List<_ActivityItem> newActivities = [];

    // Fetch Posts and Reports (Created by user)
    final eventsRef = await db.getUserEvents();
    for (var doc in eventsRef) {
      newPosts.add(_ActivityItem(
        id: doc.id,
        title: doc.title,
        description: doc.description,
        type: 'Event',
        date: doc.dateTime,
        onAction: () => _deleteItem(doc.id, 'event'),
      ));
    }

    final resourcesRef = await db.getUserResources();
    for (var doc in resourcesRef) {
      newPosts.add(_ActivityItem(
        id: doc.id,
        title: doc.title,
        description: doc.description,
        type: doc.category.name.toLowerCase() == 'hobbies' ? 'Hobby' : 'Resource',
        date: doc.postedAt,
        onAction: () => _deleteItem(doc.id, 'resource', isHobby: doc.category.name.toLowerCase() == 'hobbies'),
      ));
    }

    final feedRef = await db.getUserFeedPosts();
    for (var doc in feedRef) {
      newPosts.add(_ActivityItem(
        id: doc.id,
        title: 'Report: ${doc.type}',
        description: doc.content,
        type: 'Report',
        date: doc.timestamp,
        onAction: () => _deleteItem(doc.id, 'feed'),
      ));
    }

    // Fetch Activities / Joined Events
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final snap = await FirebaseFirestore.instance.collection('events').where('joinedBy', arrayContains: uid).get();
      for (var doc in snap.docs) {
        final data = doc.data();
        newActivities.add(_ActivityItem(
          id: doc.id,
          title: data['title'] ?? 'Event',
          description: data['description'] ?? '',
          type: 'Joined Event',
          date: (data['dateTime'] as Timestamp).toDate(),
          onAction: () => _leaveEvent(doc.id),     
        ));
      }
    }

    newPosts.sort((a, b) => b.date.compareTo(a.date));
    newActivities.sort((a, b) => b.date.compareTo(a.date));

    if (mounted) {
      setState(() {
        _posts = newPosts;
        _activities = newActivities;
        _loading = false;
      });
    }
  }

  Future<void> _leaveEvent(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.h.surface,
        title: Text('Leave Event', style: TextStyle(color: context.h.textPrimary)),
        content: Text('Are you sure you want to leave this event?', style: TextStyle(color: context.h.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Leave', style: TextStyle(color: Colors.red)),   
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirestoreService.instance.toggleEventJoin(id);
      _loadData();
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
      _loadData();
    }
  }

  Widget _buildGrid(List<_ActivityItem> items, bool isDelete) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'No content here.',
            style: AppTextStyles.bodyLarge.copyWith(color: context.h.textSecondary),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final colors = context.h;
        return Container(
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.black, width: 2),
            boxShadow: const [
              BoxShadow(
                color: AppColors.black,
                blurRadius: 0,
                offset: Offset(4, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.headlineSmall.copyWith(color: colors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    if (item.onAction != null)
                      GestureDetector(
                        onTap: item.onAction,
                        child: Icon(
                          isDelete ? Icons.delete_outline : Icons.exit_to_app, 
                          color: Colors.red, 
                          size: 20
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Text(item.description, maxLines: 3, overflow: TextOverflow.ellipsis, style: AppTextStyles.bodyMedium.copyWith(color: colors.textSecondary, fontSize: 13)),
                ),
                const SizedBox(height: 8),
                Text(
                  '${item.type}\n${item.date.month}/${item.date.day}/${item.date.year}',
                  style: AppTextStyles.caption.copyWith(color: colors.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: AppColors.black,
          unselectedLabelColor: context.h.textSecondary,
          indicatorColor: AppColors.yellow,
          tabs: const [
            Tab(text: 'Posts & Reports'),
            Tab(text: 'Activities'),
          ],
        ),
        const SizedBox(height: 16),
        _loading
          ? const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()))
          : [_buildGrid(_posts, true), _buildGrid(_activities, false)][_tabController.index],
      ],
    );
  }
}

class _ActivityItem {
  final String id;
  final String title;
  final String description;
  final String type;
  final DateTime date;
  final VoidCallback? onAction;

  _ActivityItem({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.date,
    this.onAction,
  });
}
