import 'package:flutter/material.dart';
import '../models/community_event.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';

class EventCard extends StatelessWidget {
  final CommunityEvent event;
  final VoidCallback? onTap;
  final VoidCallback? onJoin;
  final bool isJoined;
  final bool isCreator;
  final String? messageText;
  final VoidCallback? onMessageTap;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
    this.onJoin,
    this.isJoined = false,
    this.isCreator = false,
    this.messageText,
    this.onMessageTap,
  });

  String _getCategoryEmoji(String cat) {
    final c = cat.toLowerCase();
    if (c.contains('social') || c.contains('party')) return '🎉';
    if (c.contains('tech') || c.contains('code')) return '💻';
    if (c.contains('sport') || c.contains('run') || c.contains('fit')) return '🏃';
    if (c.contains('art') || c.contains('craft')) return '🎨';
    if (c.contains('food') || c.contains('cook')) return '🍔';
    if (c.contains('music') || c.contains('concert')) return '🎵';
    if (c.contains('game')) return '🎮';
    return '📅';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(24), // Enlarged container padding
        decoration: BoxDecoration(
          color: context.h.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.black, width: 2.0), // Heavy Foly border
          boxShadow: const [
            BoxShadow(
              color: AppColors.black,
              blurRadius: 0,
              offset: Offset(4, 4), // Hard offset
            ),
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
                    '${_getCategoryEmoji(event.category)} ${event.category}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.black, 
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(Icons.calendar_today_rounded, size: 14, color: context.h.iconSubtle),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM d, h:mm a').format(event.dateTime),
                  style: AppTextStyles.bodyMedium.copyWith(fontSize: 14, fontWeight: FontWeight.w600, color: context.h.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Title
            Text(event.title, style: AppTextStyles.headlineSmall.copyWith(fontSize: 22, color: context.h.textPrimary)),
            const SizedBox(height: 8),
            Text(
              event.description,
              style: AppTextStyles.bodyMedium.copyWith(height: 1.4, fontSize: 16, color: context.h.textSecondary),
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
                    style: AppTextStyles.bodyMedium.copyWith(fontSize: 14, color: context.h.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Attendance bar & Join button
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${event.attendees}/${event.maxAttendees} attending',
                        style: AppTextStyles.bodyMedium.copyWith(fontSize: 14, fontWeight: FontWeight.w600, color: context.h.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.zero, // Sharp Foly edges
                        child: LinearProgressIndicator(
                          value: event.fillPercentage,
                          backgroundColor: context.h.divider,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            event.isFull ? AppColors.red : AppColors.yellow,
                          ),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 16), // Match padding for visual balance
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (messageText != null && onMessageTap != null) ...[
                      SizedBox(
                        height: 38,
                        child: OutlinedButton.icon(
                          onPressed: onMessageTap,
                          icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                          label: Text(
                            messageText!,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.black,
                            backgroundColor: AppColors.yellow, // Solid background
                            side: const BorderSide(color: AppColors.black, width: 2), // Heavy outline
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                      SizedBox(
                        height: 38,
                        child: ElevatedButton(
                          onPressed: isCreator || (!isJoined && event.isFull) ? null : onJoin,  
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            backgroundColor: isCreator || (!isJoined && event.isFull) ? context.h.surface : (isJoined ? AppColors.green : AppColors.yellow),
                            foregroundColor: isCreator || (!isJoined && event.isFull) ? context.h.textSecondary : (isJoined ? AppColors.white : AppColors.black),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: const BorderSide(color: AppColors.black, width: 2) // Bold Border
                            ),
                            textStyle: AppTextStyles.buttonMedium.copyWith(fontSize: 13, fontWeight: FontWeight.w800),
                          ),
                          child: Text(isCreator ? 'Hosting' : (isJoined ? 'Joined' : (event.isFull ? 'Full' : 'Join'))),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
