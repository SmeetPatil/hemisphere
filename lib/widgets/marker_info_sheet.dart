import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import '../models/map_marker.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';

class MarkerInfoSheet extends StatefulWidget {
  final MapMarkerData marker;

  const MarkerInfoSheet({super.key, required this.marker});

  @override
  State<MarkerInfoSheet> createState() => _MarkerInfoSheetState();
}

class _MarkerInfoSheetState extends State<MarkerInfoSheet> {
  String? _address;
  bool _loadingAddress = true;

  @override
  void initState() {
    super.initState();
    _fetchAddress();
  }

  Future<void> _fetchAddress() async {
    final lat = widget.marker.position.latitude;
    final lng = widget.marker.position.longitude;
    final url = Uri.parse('https://nominatim.openstreetmap.org/reverse?lat=${lat}&lon=${lng}&format=json');
    try {
      final res = await http.get(url, headers: {'User-Agent': 'HemisphereApp/1.0 (flutter)'});
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (mounted) {
          setState(() {
            _address = data['display_name'];
            _loadingAddress = false;
          });
        }
      } else {
        if (mounted) setState(() => _loadingAddress = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loadingAddress = false);
    }
  }

  String _formatTime() {
    final diff = DateTime.now().difference(widget.marker.timestamp);
    if (diff.isNegative) {
      return 'Upcoming: ${DateFormat('MMM d, h:mm a').format(widget.marker.timestamp)}';
    }
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return DateFormat('MMM d, h:mm a').format(widget.marker.timestamp);
  }

  Future<void> _openDirections() async {
    final lat = widget.marker.position.latitude;
    final lng = widget.marker.position.longitude;
    final label = Uri.encodeComponent(widget.marker.title);

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
                  color: widget.marker.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(widget.marker.icon, size: 14, color: widget.marker.color),
                    const SizedBox(width: 6),
                    Text(
                      widget.marker.typeLabel,
                      style: AppTextStyles.caption.copyWith(
                        color: widget.marker.color,
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
          Text(widget.marker.title, style: AppTextStyles.headlineMedium.copyWith(color: context.h.textPrimary)),
          const SizedBox(height: 8),
          // Description
          Text(
            widget.marker.description,
            style: AppTextStyles.bodyMedium.copyWith(height: 1.5, color: context.h.textSecondary),
          ),
          const SizedBox(height: 16),
          // Reported by
          Row(
            children: [
              Icon(Icons.person_outline_rounded, size: 16, color: context.h.iconSubtle),
              const SizedBox(width: 6),
              Text(
                'Reported by ${widget.marker.reportedBy}',
                style: AppTextStyles.bodySmall.copyWith(color: context.h.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Textual Location
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on, size: 16, color: context.h.iconSubtle),
              const SizedBox(width: 6),
              Expanded(
                child: _loadingAddress 
                    ? Text('Loading address...', style: AppTextStyles.bodySmall.copyWith(color: context.h.textSecondary, fontStyle: FontStyle.italic))
                    : Text(
                        _address ?? 'Address not available',
                        style: AppTextStyles.bodySmall.copyWith(color: context.h.textPrimary, fontWeight: FontWeight.w500),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Coordinates
          Row(
            children: [
              const SizedBox(width: 22), // Account for icon width + spacing above
              Text(
                '${widget.marker.position.latitude.toStringAsFixed(4)}, ${widget.marker.position.longitude.toStringAsFixed(4)}',
                style: AppTextStyles.bodySmall.copyWith(color: context.h.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Action buttons
          if (widget.marker.type == MarkerType.accident) ...[
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
