import 'package:flutter/material.dart';
import '../models/resource_listing.dart';
import '../theme/app_theme.dart';

class ResourceCard extends StatelessWidget {
  final ResourceListing resource;
  final VoidCallback? onTap;
  final String? messageText;
  final VoidCallback? onMessageTap;

  const ResourceCard({
    super.key,
    required this.resource,
    this.onTap,
    this.messageText,
    this.onMessageTap,
  });

  String _categoryEmoji() {
    switch (resource.category) {
      case ResourceCategory.tools:
        return '🔨';
      case ResourceCategory.skills:
        return '🧠';
      case ResourceCategory.hobbies:
        return '🎨';
      case ResourceCategory.books:
        return '📚';
      case ResourceCategory.sports:
        return '⚽';
      case ResourceCategory.other:
        return '📦';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: context.h.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.black, width: 2.0),
          boxShadow: const [
            BoxShadow(
              color: AppColors.black,
              blurRadius: 0,
              offset: Offset(4, 4), // Flat heavy Foly shadow
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.yellow.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_categoryEmoji()} ${resource.category.name.toUpperCase()}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.yellow,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: resource.isAvailable
                        ? AppColors.green.withValues(alpha: 0.15)
                        : AppColors.red.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    resource.isAvailable ? 'Available' : 'In Use',
                    style: AppTextStyles.caption.copyWith(
                      color: resource.isAvailable ? AppColors.green : AppColors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              resource.title,
              style: AppTextStyles.headlineSmall.copyWith(fontSize: 18, color: context.h.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              resource.description,
              style: AppTextStyles.bodyMedium.copyWith(height: 1.3, fontSize: 14, color: context.h.textCaption),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                CircleAvatar(
                  radius: 10,
                  backgroundColor: context.h.menuIconBg,
                  child: Text(
                    resource.ownerAvatar,
                    style: const TextStyle(fontSize: 8, color: AppColors.yellow),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    resource.ownerName,
                    style: AppTextStyles.bodyMedium.copyWith(fontSize: 13, color: context.h.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (messageText != null && onMessageTap != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton.icon(
                  onPressed: onMessageTap,
                  icon: const Icon(Icons.chat_rounded, size: 16),
                  label: Text(messageText!, maxLines: 1, overflow: TextOverflow.ellipsis),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    backgroundColor: AppColors.yellow,
                    foregroundColor: AppColors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: AppColors.black, width: 2),
                    ),
                    textStyle: AppTextStyles.buttonMedium.copyWith(fontSize: 13, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
