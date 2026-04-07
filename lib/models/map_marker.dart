import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

enum MarkerType { accident, wasteCollection, communityEvent, sharedResource, roadConstruction, hobby }

class MapMarkerData {
  final String id;
  final String title;
  final String description;
  final LatLng position;
  final MarkerType type;
  final DateTime timestamp;
  final String? imageUrl;
  final String reportedBy;
  final String? neighborhoodId;

  const MapMarkerData({
    required this.id,
    required this.title,
    required this.description,
    required this.position,
    required this.type,
    required this.timestamp,
    this.imageUrl,
    required this.reportedBy,
    this.neighborhoodId,
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
      case MarkerType.roadConstruction:
        return Icons.construction_rounded;
      case MarkerType.hobby:
        return Icons.palette_rounded;
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
      case MarkerType.roadConstruction:
        return const Color(0xFF9C27B0); // Purple
      case MarkerType.hobby:
        return const Color(0xFFFF9800); // Orange
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
      case MarkerType.roadConstruction:
        return 'Road Construction';
      case MarkerType.hobby:
        return 'Hobby';
    }
  }
}
