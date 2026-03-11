import 'package:flutter/material.dart';
import '../../data/dummy_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/feed_card.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final _postController = TextEditingController();

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Feed', style: AppTextStyles.displayLarge.copyWith(color: context.h.textPrimary)),
                const SizedBox(height: 4),
                Text(
                  'What\'s happening in your neighborhood',
                  style: AppTextStyles.bodyMedium.copyWith(color: context.h.textSecondary),
                ),
              ],
            ),
          ),

          // New post composer
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: context.h.card,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: context.h.cardShadow, blurRadius: 4, offset: const Offset(0, 1)),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.yellow,
                  child: Text('Y', style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.black,
                    fontSize: 14,
                  )),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _postController,
                    style: AppTextStyles.bodyMedium.copyWith(color: context.h.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Share something with your neighbors...',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: context.h.textCaption,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    if (_postController.text.isNotEmpty) {
                      _postController.clear();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Post published!')),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.yellow,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.send_rounded, size: 18, color: AppColors.black),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Filter tabs
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _FilterTab(label: 'All', isActive: true, onTap: () {}),
                _FilterTab(label: 'Alerts', isActive: false, onTap: () {}),
                _FilterTab(label: 'Help', isActive: false, onTap: () {}),
                _FilterTab(label: 'News', isActive: false, onTap: () {}),
                _FilterTab(label: 'Updates', isActive: false, onTap: () {}),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Feed list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: DummyData.feedPosts.length,
              itemBuilder: (context, index) {
                return FeedCard(
                  post: DummyData.feedPosts[index],
                  onLike: () {},
                  onComment: () {},
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.yellow : context.h.card,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: isActive ? AppColors.black : context.h.textSecondary,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
