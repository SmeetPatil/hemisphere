import 'package:flutter/material.dart';
import '../models/feed_post.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';

class FeedCard extends StatelessWidget {
  final FeedPost post;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onComment;

  const FeedCard({
    super.key,
    required this.post,
    this.onTap,
    this.onLike,
    this.onComment,
  });

  Color _typeBadgeColor() {
    switch (post.type) {
      case PostType.alert:
        return AppColors.red;
      case PostType.helpRequest:
        return AppColors.yellow;
      case PostType.news:
        return AppColors.green;
      case PostType.update:
        return AppColors.grey600;
    }
  }

  String _timeAgo() {
    final diff = DateTime.now().difference(post.timestamp);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateFormat('MMM d').format(post.timestamp);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.h.card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: context.h.cardShadow, blurRadius: 4, offset: const Offset(0, 1)),
          ],
          border: post.type == PostType.alert
              ? Border.all(color: AppColors.red.withValues(alpha: 0.3), width: 1)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: context.h.menuIconBg,
                  child: Text(
                    post.authorAvatar,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.yellow,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.authorName, style: AppTextStyles.labelLarge.copyWith(color: context.h.textPrimary)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(_timeAgo(), style: AppTextStyles.caption.copyWith(color: context.h.textCaption)),
                          if (post.location != null) ...[
                            const SizedBox(width: 8),
                            Icon(Icons.location_on, size: 12, color: context.h.iconSubtle),
                            const SizedBox(width: 2),
                            Flexible(
                              child: Text(
                                post.location!,
                                style: AppTextStyles.caption.copyWith(color: context.h.textCaption),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _typeBadgeColor().withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    post.typeLabel,
                    style: AppTextStyles.caption.copyWith(
                      color: _typeBadgeColor(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Content
            Text(
              post.content,
              style: AppTextStyles.bodyMedium.copyWith(
                color: context.h.textTertiary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 14),
            // Actions
            Row(
              children: [
                _ActionButton(
                  icon: Icons.favorite_outline_rounded,
                  label: '${post.likes}',
                  onTap: onLike,
                ),
                const SizedBox(width: 20),
                _ActionButton(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: '${post.comments}',
                  onTap: onComment,
                ),
                const Spacer(),
                Icon(Icons.share_outlined, size: 18, color: context.h.iconSubtle),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 18, color: context.h.iconSubtle),
          const SizedBox(width: 6),
          Text(label, style: AppTextStyles.caption.copyWith(color: context.h.textCaption)),
        ],
      ),
    );
  }
}
