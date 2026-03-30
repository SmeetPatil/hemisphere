<<<<<<< HEAD
import 'package:flutter/material.dart';
import '../models/community_event.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';

class EventCard extends StatelessWidget {
  final CommunityEvent event;
  final VoidCallback? onTap;
  final VoidCallback? onJoin;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
    this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.h.card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: context.h.cardShadow, blurRadius: 4, offset: const Offset(0, 1)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category & Date
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.yellow.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    event.category,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.yellow,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(Icons.calendar_today_rounded, size: 14, color: context.h.iconSubtle),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM d, h:mm a').format(event.dateTime),
                  style: AppTextStyles.caption.copyWith(color: context.h.textCaption),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Title
            Text(event.title, style: AppTextStyles.headlineSmall.copyWith(color: context.h.textPrimary)),
            const SizedBox(height: 6),
            Text(
              event.description,
              style: AppTextStyles.bodySmall.copyWith(height: 1.4, color: context.h.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            // Location
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 16, color: context.h.iconSubtle),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    event.location,
                    style: AppTextStyles.bodySmall.copyWith(color: context.h.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Attendance bar & Join button
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${event.attendees}/${event.maxAttendees} attending',
                        style: AppTextStyles.caption.copyWith(color: context.h.textCaption),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: event.fillPercentage,
                          backgroundColor: context.h.divider,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            event.isFull ? AppColors.red : AppColors.yellow,
                          ),
                          minHeight: 4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    onPressed: event.isFull ? null : onJoin,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      textStyle: AppTextStyles.buttonMedium.copyWith(fontSize: 13),
                    ),
                    child: Text(event.isFull ? 'Full' : 'Join'),
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
=======
import 'package:flutter/material.dart';
import '../models/community_event.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';

class EventCard extends StatelessWidget {
  final CommunityEvent event;
  final VoidCallback? onTap;
  final VoidCallback? onJoin;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
    this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.h.card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: context.h.cardShadow, blurRadius: 4, offset: const Offset(0, 1)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category & Date
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.yellow.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    event.category,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.yellow,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(Icons.calendar_today_rounded, size: 14, color: context.h.iconSubtle),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM d, h:mm a').format(event.dateTime),
                  style: AppTextStyles.caption.copyWith(color: context.h.textCaption),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Title
            Text(event.title, style: AppTextStyles.headlineSmall.copyWith(color: context.h.textPrimary)),
            const SizedBox(height: 6),
            Text(
              event.description,
              style: AppTextStyles.bodySmall.copyWith(height: 1.4, color: context.h.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            // Location
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 16, color: context.h.iconSubtle),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    event.location,
                    style: AppTextStyles.bodySmall.copyWith(color: context.h.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Attendance bar & Join button
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${event.attendees}/${event.maxAttendees} attending',
                        style: AppTextStyles.caption.copyWith(color: context.h.textCaption),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: event.fillPercentage,
                          backgroundColor: context.h.divider,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            event.isFull ? AppColors.red : AppColors.yellow,
                          ),
                          minHeight: 4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    onPressed: event.isFull ? null : onJoin,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      textStyle: AppTextStyles.buttonMedium.copyWith(fontSize: 13),
                    ),
                    child: Text(event.isFull ? 'Full' : 'Join'),
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
>>>>>>> 345e37f98aab254ec09547299a58d8adbac3233b
