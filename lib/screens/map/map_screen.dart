import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../data/dummy_data.dart';
import '../../models/map_marker.dart';
import '../../theme/app_theme.dart';
import '../../widgets/marker_info_sheet.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final Set<MarkerType> _activeFilters = MarkerType.values.toSet();

  List<MapMarkerData> get _filteredMarkers => DummyData.mapMarkers
      .where((m) => _activeFilters.contains(m.type))
      .toList();

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

  void _centerMap() {
    _mapController.move(
      LatLng(DummyData.defaultLat, DummyData.defaultLng),
      14.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Map
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: LatLng(DummyData.defaultLat, DummyData.defaultLng),
            initialZoom: 14.0,
            minZoom: 10.0,
            maxZoom: 18.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.hemisphere.app',
              tileBuilder: context.isDark ? _darkModeTileBuilder : null,
            ),
            MarkerLayer(
              markers: _filteredMarkers.map((markerData) {
                return Marker(
                  point: markerData.position,
                  width: 44,
                  height: 44,
                  child: GestureDetector(
                    onTap: () => _showMarkerInfo(markerData),
                    child: _MapPin(marker: markerData),
                  ),
                );
              }).toList(),
            ),
          ],
        ),

        // Top search bar
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 16,
          right: 16,
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: context.h.surface.withValues(alpha: 0.95),
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
                  child: Text(
                    'Search your neighborhood...',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: context.h.textCaption,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.yellow,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.tune_rounded, size: 18, color: AppColors.black),
                ),
              ],
            ),
          ),
        ),

        // Filter chips
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
                      color: isActive ? AppColors.black : context.h.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                    backgroundColor: context.h.surface.withValues(alpha: 0.9),
                    selectedColor: dummy.color,
                    checkmarkColor: AppColors.black,
                    side: BorderSide(
                      color: isActive ? Colors.transparent : context.h.divider,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    visualDensity: VisualDensity.compact,
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // Recenter button
        Positioned(
          bottom: 24,
          right: 16,
          child: Column(
            children: [
              _MapActionButton(
                icon: Icons.my_location_rounded,
                onTap: _centerMap,
              ),
              const SizedBox(height: 10),
              _MapActionButton(
                icon: Icons.layers_rounded,
                onTap: () {},
              ),
            ],
          ),
        ),

        // Legend
        Positioned(
          bottom: 100,
          left: 16,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.h.surface.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('LEGEND', style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                )),
                const SizedBox(height: 8),
                _LegendItem(color: AppColors.red, label: 'Accident'),
                _LegendItem(color: AppColors.yellow, label: 'Waste'),
                _LegendItem(color: AppColors.green, label: 'Event'),
                _LegendItem(color: const Color(0xFF2196F3), label: 'Resource'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _darkModeTileBuilder(
    BuildContext context,
    Widget tileWidget,
    TileImage tile,
  ) {
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix(<double>[
        -0.2, -0.5, -0.1, 0, 255,
        -0.2, -0.5, -0.1, 0, 255,
        -0.2, -0.5, -0.1, 0, 255,
         0,    0,    0,   1,   0,
      ]),
      child: tileWidget,
    );
  }
}

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
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(
        marker.icon,
        color: AppColors.white,
        size: 22,
      ),
    );
  }
}

class _MapActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MapActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: context.h.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: context.h.cardShadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: context.h.textPrimary, size: 22),
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
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(label, style: AppTextStyles.caption.copyWith(fontSize: 10)),
        ],
      ),
    );
  }
}
