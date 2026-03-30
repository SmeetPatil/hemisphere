import 'package:flutter/material.dart';
import '../models/resource_listing.dart';
import '../theme/app_theme.dart';

class ResourceCard extends StatelessWidget {
  final ResourceListing resource;
  final VoidCallback? onTap;

  const ResourceCard({
    super.key,
    required this.resource,
    this.onTap,
  });

  IconData _categoryIcon() {
    switch (resource.category) {
      case ResourceCategory.tools:
        return Icons.build_rounded;
      case ResourceCategory.skills:
        return Icons.school_rounded;
      case ResourceCategory.hobbies:
        return Icons.palette_rounded;
      case ResourceCategory.books:
        return Icons.menu_book_rounded;
      case ResourceCategory.sports:
        return Icons.sports_tennis_rounded;
      case ResourceCategory.other:
        return Icons.category_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.h.card,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: context.h.cardShadow, blurRadius: 4, offset: const Offset(0, 1)),
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
                  child: Icon(
                    _categoryIcon(),
                    color: AppColors.yellow,
                    size: 20,
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
              style: AppTextStyles.labelLarge.copyWith(fontSize: 13, color: context.h.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              resource.description,
              style: AppTextStyles.caption.copyWith(height: 1.3, color: context.h.textCaption),
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
                    style: AppTextStyles.caption.copyWith(color: context.h.textCaption),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
