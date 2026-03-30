<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/map_marker.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';

class MarkerInfoSheet extends StatelessWidget {
  final MapMarkerData marker;

  const MarkerInfoSheet({super.key, required this.marker});

  String _formatTime() {
    final diff = DateTime.now().difference(marker.timestamp);
    if (diff.isNegative) {
      return 'Upcoming: ${DateFormat('MMM d, h:mm a').format(marker.timestamp)}';
    }
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return DateFormat('MMM d, h:mm a').format(marker.timestamp);
  }

  Future<void> _openDirections() async {
    final lat = marker.position.latitude;
    final lng = marker.position.longitude;
    final label = Uri.encodeComponent(marker.title);

    // Try geo URI first (opens native maps on Android/iOS)
    final geoUri = Uri.parse('geo:$lat,$lng?q=$lat,$lng($label)');
    if (await canLaunchUrl(geoUri)) {
      await launchUrl(geoUri);
      return;
    }

    // Fallback to Google Maps web
    final webUri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
    if (await canLaunchUrl(webUri)) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _callEmergency() async {
    final uri = Uri.parse('tel:112');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.h.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.h.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Type badge & time
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: marker.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(marker.icon, size: 14, color: marker.color),
                    const SizedBox(width: 6),
                    Text(
                      marker.typeLabel,
                      style: AppTextStyles.caption.copyWith(
                        color: marker.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Icon(Icons.access_time, size: 14, color: context.h.iconSubtle),
              const SizedBox(width: 4),
              Text(_formatTime(), style: AppTextStyles.caption.copyWith(color: context.h.textCaption)),
            ],
          ),
          const SizedBox(height: 16),
          // Title
          Text(marker.title, style: AppTextStyles.headlineMedium.copyWith(color: context.h.textPrimary)),
          const SizedBox(height: 8),
          // Description
          Text(
            marker.description,
            style: AppTextStyles.bodyMedium.copyWith(height: 1.5, color: context.h.textSecondary),
          ),
          const SizedBox(height: 16),
          // Reported by
          Row(
            children: [
              Icon(Icons.person_outline_rounded, size: 16, color: context.h.iconSubtle),
              const SizedBox(width: 6),
              Text(
                'Reported by ${marker.reportedBy}',
                style: AppTextStyles.bodySmall.copyWith(color: context.h.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Coordinates
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 16, color: context.h.iconSubtle),
              const SizedBox(width: 6),
              Text(
                '${marker.position.latitude.toStringAsFixed(4)}, ${marker.position.longitude.toStringAsFixed(4)}',
                style: AppTextStyles.bodySmall.copyWith(color: context.h.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Action buttons
          if (marker.type == MarkerType.accident) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _callEmergency,
                icon: const Icon(Icons.local_hospital_rounded),
                label: const Text('Contact Emergency Services'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.red,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _openDirections,
                icon: const Icon(Icons.directions_rounded),
                label: const Text('Get Directions'),
              ),
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _openDirections,
                icon: const Icon(Icons.directions_rounded),
                label: const Text('Get Directions'),
              ),
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
=======
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/map_marker.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';

class MarkerInfoSheet extends StatelessWidget {
  final MapMarkerData marker;

  const MarkerInfoSheet({super.key, required this.marker});

  String _formatTime() {
    final diff = DateTime.now().difference(marker.timestamp);
    if (diff.isNegative) {
      return 'Upcoming: ${DateFormat('MMM d, h:mm a').format(marker.timestamp)}';
    }
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return DateFormat('MMM d, h:mm a').format(marker.timestamp);
  }

  Future<void> _openDirections() async {
    final lat = marker.position.latitude;
    final lng = marker.position.longitude;
    final label = Uri.encodeComponent(marker.title);

    // Try geo URI first (opens native maps on Android/iOS)
    final geoUri = Uri.parse('geo:$lat,$lng?q=$lat,$lng($label)');
    if (await canLaunchUrl(geoUri)) {
      await launchUrl(geoUri);
      return;
    }

    // Fallback to Google Maps web
    final webUri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
    if (await canLaunchUrl(webUri)) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _callEmergency() async {
    final uri = Uri.parse('tel:112');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.h.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.h.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Type badge & time
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: marker.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(marker.icon, size: 14, color: marker.color),
                    const SizedBox(width: 6),
                    Text(
                      marker.typeLabel,
                      style: AppTextStyles.caption.copyWith(
                        color: marker.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Icon(Icons.access_time, size: 14, color: context.h.iconSubtle),
              const SizedBox(width: 4),
              Text(_formatTime(), style: AppTextStyles.caption.copyWith(color: context.h.textCaption)),
            ],
          ),
          const SizedBox(height: 16),
          // Title
          Text(marker.title, style: AppTextStyles.headlineMedium.copyWith(color: context.h.textPrimary)),
          const SizedBox(height: 8),
          // Description
          Text(
            marker.description,
            style: AppTextStyles.bodyMedium.copyWith(height: 1.5, color: context.h.textSecondary),
          ),
          const SizedBox(height: 16),
          // Reported by
          Row(
            children: [
              Icon(Icons.person_outline_rounded, size: 16, color: context.h.iconSubtle),
              const SizedBox(width: 6),
              Text(
                'Reported by ${marker.reportedBy}',
                style: AppTextStyles.bodySmall.copyWith(color: context.h.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Coordinates
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 16, color: context.h.iconSubtle),
              const SizedBox(width: 6),
              Text(
                '${marker.position.latitude.toStringAsFixed(4)}, ${marker.position.longitude.toStringAsFixed(4)}',
                style: AppTextStyles.bodySmall.copyWith(color: context.h.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Action buttons
          if (marker.type == MarkerType.accident) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _callEmergency,
                icon: const Icon(Icons.local_hospital_rounded),
                label: const Text('Contact Emergency Services'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.red,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _openDirections,
                icon: const Icon(Icons.directions_rounded),
                label: const Text('Get Directions'),
              ),
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _openDirections,
                icon: const Icon(Icons.directions_rounded),
                label: const Text('Get Directions'),
              ),
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
>>>>>>> 345e37f98aab254ec09547299a58d8adbac3233b
