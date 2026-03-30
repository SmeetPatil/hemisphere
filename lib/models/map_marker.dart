<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

enum MarkerType { accident, wasteCollection, communityEvent, sharedResource }

class MapMarkerData {
  final String id;
  final String title;
  final String description;
  final LatLng position;
  final MarkerType type;
  final DateTime timestamp;
  final String? imageUrl;
  final String reportedBy;

  const MapMarkerData({
    required this.id,
    required this.title,
    required this.description,
    required this.position,
    required this.type,
    required this.timestamp,
    this.imageUrl,
    required this.reportedBy,
  });

  IconData get icon {
    switch (type) {
      case MarkerType.accident:
        return Icons.warning_rounded;
      case MarkerType.wasteCollection:
        return Icons.delete_outline_rounded;
      case MarkerType.communityEvent:
        return Icons.event_rounded;
      case MarkerType.sharedResource:
        return Icons.handshake_rounded;
    }
  }

  Color get color {
    switch (type) {
      case MarkerType.accident:
        return const Color(0xFFE53935);
      case MarkerType.wasteCollection:
        return const Color(0xFFFFD600);
      case MarkerType.communityEvent:
        return const Color(0xFF43A047);
      case MarkerType.sharedResource:
        return const Color(0xFF2196F3);
    }
  }

  String get typeLabel {
    switch (type) {
      case MarkerType.accident:
        return 'Accident';
      case MarkerType.wasteCollection:
        return 'Waste Collection';
      case MarkerType.communityEvent:
        return 'Community Event';
      case MarkerType.sharedResource:
        return 'Shared Resource';
    }
  }
}
=======
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

enum MarkerType { accident, wasteCollection, communityEvent, sharedResource }

class MapMarkerData {
  final String id;
  final String title;
  final String description;
  final LatLng position;
  final MarkerType type;
  final DateTime timestamp;
  final String? imageUrl;
  final String reportedBy;

  const MapMarkerData({
    required this.id,
    required this.title,
    required this.description,
    required this.position,
    required this.type,
    required this.timestamp,
    this.imageUrl,
    required this.reportedBy,
  });

  IconData get icon {
    switch (type) {
      case MarkerType.accident:
        return Icons.warning_rounded;
      case MarkerType.wasteCollection:
        return Icons.delete_outline_rounded;
      case MarkerType.communityEvent:
        return Icons.event_rounded;
      case MarkerType.sharedResource:
        return Icons.handshake_rounded;
    }
  }

  Color get color {
    switch (type) {
      case MarkerType.accident:
        return const Color(0xFFE53935);
      case MarkerType.wasteCollection:
        return const Color(0xFFFFD600);
      case MarkerType.communityEvent:
        return const Color(0xFF43A047);
      case MarkerType.sharedResource:
        return const Color(0xFF2196F3);
    }
  }

  String get typeLabel {
    switch (type) {
      case MarkerType.accident:
        return 'Accident';
      case MarkerType.wasteCollection:
        return 'Waste Collection';
      case MarkerType.communityEvent:
        return 'Community Event';
      case MarkerType.sharedResource:
        return 'Shared Resource';
    }
  }
}
>>>>>>> 345e37f98aab254ec09547299a58d8adbac3233b
