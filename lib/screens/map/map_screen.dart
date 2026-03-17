import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/dummy_data.dart';
import '../../models/map_marker.dart';
import '../../theme/app_theme.dart';
import '../../widgets/marker_info_sheet.dart';

// Simple geocode result from OSM Nominatim
class _GeoResult {
  final String displayName;
  final double lat;
  final double lng;
  const _GeoResult(this.displayName, this.lat, this.lng);
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  final Set<MarkerType> _activeFilters = MarkerType.values.toSet();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  LatLng? _userLocation;
  bool _loadingLocation = false;
  bool _isSearchBarActive = false;
  bool _isLegendExpanded = false;
  List<_GeoResult> _searchResults = [];
  bool _searchLoading = false;
  String? _searchError;
  Timer? _searchDebounce;
  StreamSubscription<Position>? _locationSub;

  // Pulse animation for user dot
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  List<MapMarkerData> get _filteredMarkers => DummyData.mapMarkers
      .where((m) => _activeFilters.contains(m.type))
      .toList();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.8, end: 1.4).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    // Don't auto-fetch location on init — user taps the FAB to request it
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    _searchDebounce?.cancel();
    _locationSub?.cancel();
    super.dispose();
  }

  // ── Location ──────────────────────────────────────────────────────────────


  Future<void> _fetchLocation() async {
    if (mounted) setState(() => _loadingLocation = true);

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        _showSnack('Location services disabled. Please enable GPS.',
            isError: true);
        setState(() => _loadingLocation = false);
      }
      return;
    }

    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      if (mounted) {
        _showSnack('Location permission denied.', isError: true);
        setState(() => _loadingLocation = false);
      }
      return;
    }

    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      final loc = LatLng(pos.latitude, pos.longitude);
      if (mounted) {
        setState(() {
          _userLocation = loc;
          _loadingLocation = false;
        });
        _mapController.move(loc, 15.0);
      }
      // Start live stream to keep dot updated
      _locationSub?.cancel();
      _locationSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen((p) {
        if (mounted) {
          setState(() => _userLocation = LatLng(p.latitude, p.longitude));
        }
      });
    } catch (_) {
      if (mounted) {
        setState(() => _loadingLocation = false);
        _showSnack('Could not get your location.', isError: true);
      }
    }
  }

  void _centerOnUser() {
    if (_userLocation != null) {
      _mapController.move(_userLocation!, 15.0);
    } else {
      _fetchLocation();
    }
  }

  void _centerOnDefault() {
    _mapController.move(
        LatLng(DummyData.defaultLat, DummyData.defaultLng), 14.0);
  }

  // ── Search via OSM Nominatim ──────────────────────────────────────────────

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _searchError = null;
      });
      return;
    }
    _searchDebounce = Timer(
        const Duration(milliseconds: 600), () => _runSearch(query.trim()));
  }

  Future<void> _runSearch(String query) async {
    if (!mounted) return;
    setState(() {
      _searchLoading = true;
      _searchError = null;
    });
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
        '?q=${Uri.encodeComponent(query)}&format=json&limit=5',
      );
      final response = await http.get(uri, headers: {
        'User-Agent': 'HemisphereApp/1.0 (flutter)',
        'Accept-Language': 'en',
      }).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final results = data.map((item) {
          return _GeoResult(
            item['display_name'] as String,
            double.parse(item['lat'] as String),
            double.parse(item['lon'] as String),
          );
        }).toList();
        setState(() {
          _searchResults = results;
          _searchLoading = false;
          if (results.isEmpty) _searchError = 'No results found for "$query"';
        });
      } else {
        setState(() {
          _searchResults = [];
          _searchError = 'Search failed. Try again.';
          _searchLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _searchError = 'No results found for "$query"';
          _searchLoading = false;
        });
      }
    }
  }

  void _selectSearchResult(_GeoResult result) {
    _mapController.move(LatLng(result.lat, result.lng), 15.0);
    setState(() {
      _isSearchBarActive = false;
      _searchResults = [];
      _searchController.clear();
      _searchError = null;
    });
    _searchFocus.unfocus();
  }

  void _closeSearch() {
    _searchController.clear();
    _searchFocus.unfocus();
    setState(() {
      _isSearchBarActive = false;
      _searchResults = [];
      _searchError = null;
    });
  }

  // ── Markers / Filters ────────────────────────────────────────────────────

  void _showMarkerInfo(MapMarkerData marker) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => MarkerInfoSheet(marker: marker),
    );
  }

  void _toggleFilter(MarkerType type) {
    setState(() {
      if (_activeFilters.contains(type)) {
        if (_activeFilters.length > 1) _activeFilters.remove(type);
      } else {
        _activeFilters.add(type);
      }
    });
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppColors.red : AppColors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }



  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Nav bar height (65) + system bottom inset so FABs/legend clear the bar
    final bottomInset = MediaQuery.of(context).padding.bottom;
    const navBarHeight = 65.0;
    final safeBottom = navBarHeight + bottomInset;

    return Stack(
      children: [
        // ── OSM Map ───────────────────────────────────────────────────────
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: LatLng(DummyData.defaultLat, DummyData.defaultLng),
            initialZoom: 14.0,
            minZoom: 4.0,
            maxZoom: 19.0,
            onTap: (_, __) {
              if (_isSearchBarActive) _closeSearch();
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.hemisphere.app',
              tileBuilder: null, // Always use light mode for map tiles
            ),
            // Incident / Event Markers
            MarkerLayer(
              markers: [
                // User location marker
                if (_userLocation != null)
                  Marker(
                    point: _userLocation!,
                    width: 52,
                    height: 52,
                    child: AnimatedBuilder(
                      animation: _pulseAnim,
                      builder: (_, child) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 44 * _pulseAnim.value,
                              height: 44 * _pulseAnim.value,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0x331E88E5),
                              ),
                            ),
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF1E88E5),
                                border: Border.all(
                                    color: Colors.white, width: 2.5),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x441E88E5),
                                    blurRadius: 6,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                // Incident markers
                ..._filteredMarkers.map((m) {
                  return Marker(
                    point: m.position,
                    width: 30, // Smaller size
                    height: 30, // Smaller size
                    child: GestureDetector(
                      onTap: () => _showMarkerInfo(m),
                      child: _MapPin(marker: m),
                    ),
                  );
                }),
              ],
            ),
          ],
        ),

        // ── Search Bar + Dropdown ─────────────────────────────────────────
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 16,
          right: 16,
          child: Column(
            children: [
              // Input row
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: context.h.surface.withValues(alpha: 0.97),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: context.h.cardShadow,
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 14),
                    Icon(Icons.search_rounded, color: context.h.iconSubtle),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocus,
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: context.h.textPrimary),
                        decoration: InputDecoration.collapsed(
                          hintText: 'Search your neighborhood...',
                          hintStyle: AppTextStyles.bodyMedium
                              .copyWith(color: context.h.textCaption),
                        ),
                        onTap: () =>
                            setState(() => _isSearchBarActive = true),
                        onChanged: (v) {
                          setState(() => _isSearchBarActive = true);
                          _onSearchChanged(v);
                        },
                        onSubmitted: (v) {
                          if (v.trim().isNotEmpty) _runSearch(v.trim());
                        },
                      ),
                    ),
                    if (_isSearchBarActive)
                      GestureDetector(
                        onTap: _closeSearch,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Icon(Icons.close_rounded,
                              size: 20, color: context.h.iconSubtle),
                        ),
                      )
                    else
                      Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.yellow,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.tune_rounded,
                            size: 18, color: AppColors.black),
                      ),
                  ],
                ),
              ),

              // Search results dropdown
              if (_isSearchBarActive &&
                  (_searchResults.isNotEmpty ||
                      _searchLoading ||
                      _searchError != null))
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  constraints: const BoxConstraints(maxHeight: 240),
                  decoration: BoxDecoration(
                    color: context.h.surface,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: context.h.cardShadow,
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _searchLoading
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2),
                            ),
                          ),
                        )
                      : _searchError != null
                          ? Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Icon(Icons.search_off_rounded,
                                      size: 18,
                                      color: context.h.textCaption),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _searchError!,
                                      style: AppTextStyles.bodySmall
                                          .copyWith(
                                              color: context.h.textCaption),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 6),
                              itemCount: _searchResults.length,
                              separatorBuilder: (_, __) => Divider(
                                height: 1,
                                color: context.h.divider,
                                indent: 16,
                                endIndent: 16,
                              ),
                              itemBuilder: (_, i) {
                                final r = _searchResults[i];
                                return ListTile(
                                  dense: true,
                                  leading: const Icon(
                                      Icons.location_on_rounded,
                                      size: 18,
                                      color: AppColors.yellow),
                                  title: Text(
                                    r.displayName,
                                    style: AppTextStyles.bodySmall
                                        .copyWith(
                                            color: context.h.textPrimary,
                                            fontWeight: FontWeight.w600),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    '${r.lat.toStringAsFixed(4)}, ${r.lng.toStringAsFixed(4)}',
                                    style: AppTextStyles.caption.copyWith(
                                        color: context.h.textCaption),
                                  ),
                                  onTap: () => _selectSearchResult(r),
                                );
                              },
                            ),
                ),
            ],
          ),
        ),

        // ── Filter Chips ──────────────────────────────────────────────────
        if (!_isSearchBarActive)
          Positioned(
            top: MediaQuery.of(context).padding.top + 66,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: MarkerType.values.map((type) {
                  final isActive = _activeFilters.contains(type);
                  final dummy = MapMarkerData(
                    id: '',
                    title: '',
                    description: '',
                    position: LatLng(0, 0),
                    type: type,
                    timestamp: DateTime.now(),
                    reportedBy: '',
                  );
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isActive,
                      onSelected: (_) => _toggleFilter(type),
                      label: Text(dummy.typeLabel),
                      labelStyle: AppTextStyles.caption.copyWith(
                        color: isActive
                            ? AppColors.black
                            : context.h.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                      backgroundColor:
                          context.h.surface.withValues(alpha: 0.9),
                      selectedColor: dummy.color,
                      checkmarkColor: AppColors.black,
                      side: BorderSide(
                          color: isActive
                              ? Colors.transparent
                              : context.h.divider),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      visualDensity: VisualDensity.compact,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

        // ── Right-side FABs ───────────────────────────────────────────────
        Positioned(
          bottom: safeBottom - 6,
          right: 16,
          child: Column(
            children: [
              _MapActionButton(
                icon: _loadingLocation
                    ? Icons.hourglass_top_rounded
                    : _userLocation != null
                        ? Icons.my_location_rounded
                        : Icons.location_searching_rounded,
                onTap: _centerOnUser,
                highlight: _userLocation != null && !_loadingLocation,
              ),
              const SizedBox(height: 10),
              _MapActionButton(
                icon: Icons.home_rounded,
                onTap: _centerOnDefault,
              ),
            ],
          ),
        ),

        // ── Legend ────────────────────────────────────────────────────────
        Positioned(
          bottom: safeBottom - 18,
          left: 16,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _isLegendExpanded = !_isLegendExpanded;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: context.h.surface.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: context.h.cardShadow.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                alignment: Alignment.bottomLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.layers_rounded, size: 18, color: context.h.textPrimary),
                        const SizedBox(width: 8),
                        Text(
                          'LEGEND',
                          style: AppTextStyles.caption.copyWith(
                              color: context.h.textPrimary,
                              fontWeight: FontWeight.w700, letterSpacing: 1),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _isLegendExpanded ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_up_rounded,
                          size: 18,
                          color: context.h.textSecondary,
                        ),
                      ],
                    ),
                    if (_isLegendExpanded) ...[
                      const SizedBox(height: 12),
                      const _LegendItem(color: AppColors.red, label: 'Accident'),
                      const _LegendItem(color: AppColors.yellow, label: 'Waste'),
                      const _LegendItem(color: AppColors.green, label: 'Event'),
                      const _LegendItem(
                          color: Color(0xFF2196F3), label: 'Resource'),
                      const _LegendItem(
                          color: Color(0xFF1E88E5), label: 'You'),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── Location loading pill ─────────────────────────────────────────
        if (_loadingLocation)
          Positioned(
            bottom: safeBottom + 16,
            right: 70,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: context.h.surface,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(color: context.h.cardShadow, blurRadius: 8),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.yellow),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Getting location…',
                    style: AppTextStyles.caption
                        .copyWith(color: context.h.textSecondary),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _MapPin extends StatelessWidget {
  final MapMarkerData marker;
  const _MapPin({required this.marker});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: marker.color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: marker.color.withValues(alpha: 0.4),
            blurRadius: 4, // reduced blur
            spreadRadius: 1, // reduced spread
          ),
        ],
      ),
      child: Icon(marker.icon, color: AppColors.white, size: 16), // Smaller icon
    );
  }
}

class _MapActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool highlight;

  const _MapActionButton(
      {required this.icon, required this.onTap, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: highlight ? AppColors.yellow : context.h.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: context.h.cardShadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon,
            color: highlight ? AppColors.black : context.h.textPrimary,
            size: 22),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(label, style: AppTextStyles.caption.copyWith(fontSize: 10)),
        ],
      ),
    );
  }
}
