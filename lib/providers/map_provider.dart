<<<<<<< HEAD
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

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
  LocationStatus _locationStatus = LocationStatus.initial;
  List<NominatimResult> _searchResults = [];
  bool _isSearching = false;
  String? _searchError;

  LatLng? get userLocation => _userLocation;
  LocationStatus get locationStatus => _locationStatus;
  List<NominatimResult> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  String? get searchError => _searchError;

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
      notifyListeners();
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
    ).map((pos) {
      _userLocation = LatLng(pos.latitude, pos.longitude);
      notifyListeners();
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
=======
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

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
  LocationStatus _locationStatus = LocationStatus.initial;
  List<NominatimResult> _searchResults = [];
  bool _isSearching = false;
  String? _searchError;

  LatLng? get userLocation => _userLocation;
  LocationStatus get locationStatus => _locationStatus;
  List<NominatimResult> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  String? get searchError => _searchError;

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
      notifyListeners();
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
    ).map((pos) {
      _userLocation = LatLng(pos.latitude, pos.longitude);
      notifyListeners();
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
>>>>>>> 345e37f98aab254ec09547299a58d8adbac3233b
