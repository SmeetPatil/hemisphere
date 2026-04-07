import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

import '../models/neighborhood.dart';
import '../services/firestore_service.dart';

class NominatimResult {
  final String displayName;
  final double latitude;
  final double longitude;
  const NominatimResult(this.displayName, this.latitude, this.longitude);
}

enum LocationStatus { initial, loading, granted, denied, disabled }

class MapProvider extends ChangeNotifier {
  static final MapProvider instance = MapProvider._();
  MapProvider._();

  LatLng? _userLocation;
  Neighborhood? _currentNeighborhood;
  LocationStatus _locationStatus = LocationStatus.initial;
  List<NominatimResult> _searchResults = [];
  bool _isSearching = false;
  String? _searchError;

  LatLng? get userLocation => _userLocation;
  LocationStatus get locationStatus => _locationStatus;
  List<NominatimResult> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  String? get searchError => _searchError;
  Neighborhood? get currentNeighborhood => _currentNeighborhood;
  String? get currentNeighborhoodId => _currentNeighborhood?.id;

  Future<void> _updateNeighborhood(LatLng position) async {
    final newNbhd = MumbaiNeighborhoods.findNeighborhoodFor(position);
    if (newNbhd != null) {
      _currentNeighborhood = newNbhd;
      notifyListeners();
    } else {
      // Fallback to home profile if out of bounds
      final profile = await FirestoreService.instance.getProfile();
      if (profile != null && profile['homeNeighborhoodId'] != null) {
        final homeId = profile['homeNeighborhoodId'];
        _currentNeighborhood = MumbaiNeighborhoods.regions.firstWhere(
          (n) => n.id == homeId,
          orElse: () => MumbaiNeighborhoods.regions.first, // or null
        );
      } else {
         // Default if completely unset
         _currentNeighborhood = null;
      }
      notifyListeners();
    }
  }

  Future<void> setHomeNeighborhood(LatLng location, String neighborhoodId) async {
    await FirestoreService.instance.setHomeLocation(location.latitude, location.longitude, neighborhoodId);
    if (_currentNeighborhood == null) {
      _currentNeighborhood = MumbaiNeighborhoods.regions.firstWhere(
        (n) => n.id == neighborhoodId,
        orElse: () => MumbaiNeighborhoods.regions.first,
      );
      notifyListeners();
    }
  }

  /// Request location permission and get current position
  Future<LatLng?> requestAndGetLocation() async {
    _locationStatus = LocationStatus.loading;
    notifyListeners();

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _locationStatus = LocationStatus.disabled;
      notifyListeners();
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _locationStatus = LocationStatus.denied;
        notifyListeners();
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _locationStatus = LocationStatus.denied;
      notifyListeners();
      return null;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      _userLocation = LatLng(position.latitude, position.longitude);
      _locationStatus = LocationStatus.granted;
      await _updateNeighborhood(_userLocation!);
      return _userLocation;
    } catch (e) {
      _locationStatus = LocationStatus.denied;
      notifyListeners();
      return null;
    }
  }

  /// Stream of live location updates
  Stream<LatLng> get locationStream {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).asyncMap((pos) async {
      _userLocation = LatLng(pos.latitude, pos.longitude);
      await _updateNeighborhood(_userLocation!);
      return _userLocation!;
    });
  }

  /// Geocode an address query to coordinates
  Future<List<NominatimResult>> searchAddress(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      _searchError = null;
      notifyListeners();
      return [];
    }

    _isSearching = true;
    _searchError = null;
    notifyListeners();

    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
        '?q=${Uri.encodeComponent(query)}&format=json&limit=5',
      );
      final response = await http.get(uri, headers: {
        'User-Agent': 'HemisphereApp/1.0 (flutter)',
        'Accept-Language': 'en',
      }).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _searchResults = data.map((item) {
          return NominatimResult(
            item['display_name'] as String,
            double.parse(item['lat'] as String),
            double.parse(item['lon'] as String),
          );
        }).toList();
        if (_searchResults.isEmpty) {
          _searchError = 'No results found for "$query"';
        }
      } else {
        _searchResults = [];
        _searchError = 'Search failed. Try again.';
      }
    } catch (_) {
      _searchResults = [];
      _searchError = 'No results found for "$query"';
    }

    _isSearching = false;
    notifyListeners();
    return _searchResults;
  }

  void clearSearch() {
    _searchResults = [];
    _searchError = null;
    notifyListeners();
  }
}
