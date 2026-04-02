import 'package:flutter/material.dart';

import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';

class FollowersScreen extends StatefulWidget {
  final int initialTab; // 0 = Followers, 1 = Following

  const FollowersScreen({super.key, this.initialTab = 0});

  @override
  State<FollowersScreen> createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _followers = [];
  List<Map<String, dynamic>> _following = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 2, vsync: this, initialIndex: widget.initialTab);
    _load();
  }

  Future<void> _load() async {
    final followers = await FirestoreService.instance.getFollowers();
    final following = await FirestoreService.instance.getFollowing();
    if (!mounted) return;
    setState(() {
      _followers = followers;
      _following = following;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.h;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Connections',
          style:
              AppTextStyles.headlineMedium.copyWith(color: colors.textPrimary),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.yellow, width: 3),
            ),
          ),
          labelColor: AppColors.yellow,
          unselectedLabelColor: colors.textCaption,
          labelStyle: AppTextStyles.labelLarge,
          unselectedLabelStyle: AppTextStyles.labelMedium,
          tabs: [
            Tab(text: 'Followers (${_followers.length})'),
            Tab(text: 'Following (${_following.length})'),
          ],
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.yellow))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildList(_followers, isFollowerTab: true),
                _buildList(_following, isFollowerTab: false),
              ],
            ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> users,
      {required bool isFollowerTab}) {
    final colors = context.h;

    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isFollowerTab
                  ? Icons.people_outline_rounded
                  : Icons.person_add_alt_1_rounded,
              size: 56,
              color: colors.textCaption,
            ),
            const SizedBox(height: 12),
            Text(
              isFollowerTab
                  ? 'No followers yet'
                  : 'Not following anyone yet',
              style:
                  AppTextStyles.bodyMedium.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              isFollowerTab
                  ? 'Share your profile to get followers'
                  : 'Discover people in the community',
              style: AppTextStyles.caption.copyWith(color: colors.textCaption),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final user = users[index];
        final name = user['displayName'] ?? 'User';
        final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: colors.cardShadow,
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar
              (user['photoUrl'] ?? '').toString().isNotEmpty
                  ? CircleAvatar(
                      radius: 22,
                      backgroundImage: NetworkImage(user['photoUrl']),
                      backgroundColor:
                          AppColors.yellow.withValues(alpha: 0.2),
                    )
                  : Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.yellow.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: AppColors.yellow, width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          initial,
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.yellow,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
              const SizedBox(width: 12),

              // Name + email
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if ((user['email'] ?? '').toString().isNotEmpty)
                      Text(
                        user['email'],
                        style: AppTextStyles.caption
                            .copyWith(color: colors.textCaption),
                      ),
                  ],
                ),
              ),

              // Follow/Unfollow button
              if (!isFollowerTab)
                TextButton(
                  onPressed: () async {
                    await FirestoreService.instance
                        .unfollowUser(user['id']);
                    _load();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.red,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                  ),
                  child: const Text('Unfollow'),
                ),
            ],
          ),
        );
      },
    );
  }
}
