import 'package:latlong2/latlong.dart';
import 'dart:math' as math;

class Neighborhood {
  final String id;
  final String name;
  final String landmark;
  final LatLng center;
  final double hexagonSizeMeters; // Size of the hexagonal geofence (distance from center to vertex)

  const Neighborhood({
    required this.id,
    required this.name,
    required this.landmark,
    required this.center,
    this.hexagonSizeMeters = 3000.0, // Default 3km size
  });

  /// Calculate distance from this neighborhood's center to a given point in meters
  double distanceTo(LatLng point) {
    const double R = 6371000; // Earth radius in meters
    final double phi1 = center.latitude * math.pi / 180;
    final double phi2 = point.latitude * math.pi / 180;
    final double deltaPhi = (point.latitude - center.latitude) * math.pi / 180;
    final double deltaLambda = (point.longitude - center.longitude) * math.pi / 180;

    final double a = math.sin(deltaPhi / 2) * math.sin(deltaPhi / 2) +
        math.cos(phi1) * math.cos(phi2) *
            math.sin(deltaLambda / 2) * math.sin(deltaLambda / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return R * c;
  }

  /// Checks if a given coordinate falls within this neighborhood's hexagonal geofence
  bool contains(LatLng point) {
    return _isInsideHexagon(point);
  }

  bool _isInsideHexagon(LatLng point) {
    // Generate the 6 vertices of the hexagon
    final vertices = <LatLng>[];
    for (int i = 0; i < 6; i++) {
      // 0, 60, 120, 180, 240, 300 degrees
      final angle = (i * 60) * math.pi / 180;
      // Convert distance to degrees lat/lng
      // 1 degree lat ~ 111320 meters
      final latOffset = (hexagonSizeMeters / 111320) * math.cos(angle);
      // 1 degree lng ~ 111320 * cos(lat) meters
      final lngOffset = (hexagonSizeMeters / (111320 * math.cos(center.latitude * math.pi / 180))) * math.sin(angle);
      
      vertices.add(LatLng(
        center.latitude + latOffset,
        center.longitude + lngOffset,
      ));
    }

    // Ray casting algorithm for point in polygon
    int intersections = 0;
    for (int i = 0; i < vertices.length; i++) {
      final p1 = vertices[i];
      final p2 = vertices[(i + 1) % vertices.length];
      
      if ((p1.latitude <= point.latitude && point.latitude < p2.latitude) ||
          (p2.latitude <= point.latitude && point.latitude < p1.latitude)) {
        final xinters = (point.latitude - p1.latitude) / 
                        (p2.latitude - p1.latitude) * 
                        (p2.longitude - p1.longitude) + p1.longitude;
        if (point.longitude < xinters) {
          intersections++;
        }
      }
    }
    
    return intersections % 2 == 1;
  }
}

class MumbaiNeighborhoods {
  static const List<Neighborhood> regions = [
    Neighborhood(
      id: 'n_chikoowadi',
      name: 'Chikoowadi',
      landmark: 'Banana Leaf Restaurant',
      center: LatLng(19.2217, 72.8425),
      hexagonSizeMeters: 4000,
    ),
    Neighborhood(
      id: 'n_bandra',
      name: 'Bandra',
      landmark: 'Mount Mary Church',
      center: LatLng(19.0465, 72.8226),
      hexagonSizeMeters: 4000,
    ),
    Neighborhood(
      id: 'n_andheri',
      name: 'Andheri',
      landmark: 'Kokilaben Hospital',
      center: LatLng(19.1311, 72.8248),
      hexagonSizeMeters: 4000,
    ),
    Neighborhood(
      id: 'n_powai',
      name: 'Powai',
      landmark: 'Hiranandani Gardens',
      center: LatLng(19.1172, 72.9060),
      hexagonSizeMeters: 4000,
    ),
    Neighborhood(
      id: 'n_colaba',
      name: 'Colaba',
      landmark: 'Gateway of India',
      center: LatLng(18.9220, 72.8347),
      hexagonSizeMeters: 4000,
    ),
    Neighborhood(
      id: 'n_worli',
      name: 'Worli',
      landmark: 'Worli Sea Face',
      center: LatLng(19.0069, 72.8156),
      hexagonSizeMeters: 4000,
    ),
  ];

  /// Find the neighborhood a specific location belongs to.
  /// If it falls into multiple intersecting radiuses, it picks the closest center point.
  /// Returns null if the location is outside all defined Mumbai geofences.
  static Neighborhood? findNeighborhoodFor(LatLng location) {
    Neighborhood? closest;
    double minDistance = double.infinity;

    for (var n in regions) {
      if (n.contains(location)) {
        double dist = n.distanceTo(location);
        if (dist < minDistance) {
          minDistance = dist;
          closest = n;
        }
      }
    }
    return closest;
  }
}
