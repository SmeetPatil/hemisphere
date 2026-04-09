import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/neighborhood.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../theme/app_theme.dart';
import '../../models/community_event.dart';
import '../../models/resource_listing.dart';
import '../../services/firestore_service.dart';
import '../../providers/map_provider.dart';

class _CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final int maxLines;
  final IconData? icon;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;

  const _CustomTextField({
    this.controller,
    required this.hintText,
    this.maxLines = 1,
    this.icon,
    this.readOnly = false,
    this.onTap,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.h.inputFill,
        borderRadius: BorderRadius.circular(10), // Foly inputs
        border: Border.all(
          color: AppColors.black,
          width: 2,
        ), // Heavy black border
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: keyboardType,
        style: AppTextStyles.bodyMedium.copyWith(color: context.h.textPrimary),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: context.h.textCaption,
          ),
          prefixIcon: icon != null
              ? Icon(icon, color: context.h.textSecondary, size: 20)
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Post'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
        leading: const SizedBox.shrink(),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: context.h.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.black, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.black,
                  offset: Offset(4, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                _buildSegment(0, 'Event'),
                _buildSegment(1, 'Resource'),
                _buildSegment(2, 'Hobby'),
              ],
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: const [
                _EventForm(),
                _ResourceForm(isHobby: false),
                _ResourceForm(isHobby: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegment(int index, String label) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.yellow : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.black : Colors.transparent,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.labelLarge.copyWith(
                color: isSelected ? AppColors.black : context.h.textSecondary,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EventForm extends StatefulWidget {
  const _EventForm();

  @override
  State<_EventForm> createState() => _EventFormState();
}

class _EventFormState extends State<_EventForm> {
  final _titleC = TextEditingController();
  final _descC = TextEditingController();
  final _locC = TextEditingController();
  final _categoryC = TextEditingController(text: 'Social');
  final _attendeesC = TextEditingController(text: '20');

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = TimeOfDay.now();
  LatLng? _selectedLatLng;

  String get _currentUserName =>
      FirebaseAuth.instance.currentUser?.displayName ??
      FirebaseAuth.instance.currentUser?.email?.split('@').first ??
      'User';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _pickMapLocation() async {
    final result = await Navigator.push<_LocationResult>(
      context,
      MaterialPageRoute(
        builder: (_) => _LocationPickerScreen(initialLocation: _selectedLatLng),
      ),
    );
    if (result != null) {
      setState(() {
        _selectedLatLng = result.point;
        _locC.text = result.address;
      });
    }
  }

  Future<void> _submit() async {
    if (_titleC.text.isEmpty || _descC.text.isEmpty) return;

    final dateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final newEvent = CommunityEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleC.text,
      description: _descC.text,
      organizer: _currentUserName,
      dateTime: dateTime,
      location: _locC.text.isEmpty ? 'TBD' : _locC.text,
      category: _categoryC.text,
      attendees: 1,
      maxAttendees: int.tryParse(_attendeesC.text) ?? 20,
      latitude: _selectedLatLng?.latitude,
      longitude: _selectedLatLng?.longitude,
      neighborhoodId: MapProvider.instance.currentNeighborhoodId,
    );
    await FirestoreService.instance.addEvent(newEvent);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _CustomTextField(
          controller: _titleC,
          hintText: 'Event Title (What is happening?)',
          icon: Icons.title_rounded,
        ),
        const SizedBox(height: 16),
        _CustomTextField(
          controller: _locC,
          hintText: 'Location (Pick on map)',
          icon: Icons.location_on_rounded,
          readOnly: true,
          onTap: _pickMapLocation,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _CustomTextField(
                controller: TextEditingController(
                  text:
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                ),
                hintText: 'Date',
                icon: Icons.calendar_today_rounded,
                readOnly: true,
                onTap: _pickDate,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _CustomTextField(
                controller: TextEditingController(
                  text: _selectedTime.format(context),
                ),
                hintText: 'Time',
                icon: Icons.access_time_rounded,
                readOnly: true,
                onTap: _pickTime,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _CustomTextField(
                controller: _categoryC,
                hintText: 'Category (e.g. Social, Tech)',
                icon: Icons.category_rounded,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _CustomTextField(
                controller: _attendeesC,
                hintText: 'Max People (e.g. 20)',
                icon: Icons.people_rounded,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _CustomTextField(
          controller: _descC,
          maxLines: 4,
          hintText: 'Description (Provide details about the event)',
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.yellow,
            foregroundColor: AppColors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.black, width: 2),
            ),
            elevation: 0,
          ),
          child: Text(
            'Create Event',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _ResourceForm extends StatefulWidget {
  final bool isHobby;
  const _ResourceForm({required this.isHobby});

  @override
  State<_ResourceForm> createState() => _ResourceFormState();
}

class _ResourceFormState extends State<_ResourceForm> {
  final _titleC = TextEditingController();
  final _descC = TextEditingController();
  final _locC = TextEditingController();
  LatLng? _selectedLatLng;

  String get _currentUserName =>
      FirebaseAuth.instance.currentUser?.displayName ??
      FirebaseAuth.instance.currentUser?.email?.split('@').first ??
      'User';

  Future<void> _pickMapLocation() async {
    final result = await Navigator.push<_LocationResult>(
      context,
      MaterialPageRoute(
        builder: (_) => _LocationPickerScreen(initialLocation: _selectedLatLng),
      ),
    );
    if (result != null) {
      setState(() {
        _selectedLatLng = result.point;
        _locC.text = result.address;
      });
    }
  }

  Future<void> _submit() async {
    if (_titleC.text.isEmpty || _descC.text.isEmpty) return;

    final newRes = ResourceListing(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleC.text,
      description: _descC.text,
      ownerName: _currentUserName,
      ownerAvatar: 'ME',
      category: widget.isHobby
          ? ResourceCategory.hobbies
          : ResourceCategory.tools,
      isAvailable: true,
      postedAt: DateTime.now(),
      latitude: _selectedLatLng?.latitude,
      longitude: _selectedLatLng?.longitude,
      neighborhoodId: MapProvider.instance.currentNeighborhoodId,
    );
    await FirestoreService.instance.addResource(newRes);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _CustomTextField(
          controller: _titleC,
          hintText: widget.isHobby
              ? 'Hobby Title (e.g. Weekend Cycling)'
              : 'Resource Title (e.g. Power Drill)',
          icon: widget.isHobby
              ? Icons.sports_tennis_rounded
              : Icons.build_rounded,
        ),
        const SizedBox(height: 16),
        _CustomTextField(
          controller: _locC,
          hintText: 'Location (Pick on map)',
          icon: Icons.location_on_rounded,
          readOnly: true,
          onTap: _pickMapLocation,
        ),
        const SizedBox(height: 16),
        _CustomTextField(
          controller: _descC,
          maxLines: 4,
          hintText: widget.isHobby
              ? 'Description (Tell us about your hobby)'
              : 'Description (Describe the resource you are sharing)',
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.yellow,
            foregroundColor: AppColors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.black, width: 2),
            ),
            elevation: 0,
          ),
          child: Text(
            widget.isHobby ? 'Post Hobby' : 'Post Resource',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _GeoResult {
  final LatLng coords;
  final String displayName;
  _GeoResult(this.coords, this.displayName);
}

class _LocationResult {
  final LatLng point;
  final String address;
  _LocationResult(this.point, this.address);
}

class _LocationPickerScreen extends StatefulWidget {
  final LatLng? initialLocation;
  const _LocationPickerScreen({super.key, this.initialLocation});

  @override
  State<_LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<_LocationPickerScreen> {
  LatLng? _pickedLoc;
  final MapController _mapController = MapController();
  final TextEditingController _searchC = TextEditingController();
  List<_GeoResult> _searchResults = [];
  Timer? _debounce;
  bool _isLoadingAddress = false;
  String? _currentAddress;

  @override
  void initState() {
    super.initState();
    _pickedLoc = widget.initialLocation ?? const LatLng(19.0760, 72.8777);
    _initLocation();
  }

  Future<void> _initLocation() async {
    if (widget.initialLocation != null) {
      _reverseGeocode(_pickedLoc!);
      return;
    }

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position pos = await Geolocator.getCurrentPosition();
        if (mounted) {
          setState(() {
            _pickedLoc = LatLng(pos.latitude, pos.longitude);
            _mapController.move(_pickedLoc!, 14.0);
          });
          _reverseGeocode(_pickedLoc!);
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchC.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    if (query.length < 3) {
      setState(() => _searchResults = []);
      return;
    }
    _debounce = Timer(
      const Duration(milliseconds: 500),
      () => _performSearch(query),
    );
  }

  Future<void> _performSearch(String query) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=5&bounded=1&viewbox=72.75,19.25,73.0,18.85',
    );
    try {
      final res = await http.get(url, headers: {'User-Agent': 'HemisphereApp'});
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        setState(() {
          _searchResults = data.map((json) {
            return _GeoResult(
              LatLng(double.parse(json['lat']), double.parse(json['lon'])),
              json['display_name'] ?? '',
            );
          }).toList();
        });
      }
    } catch (_) {}
  }

  Future<void> _reverseGeocode(LatLng pts) async {
    setState(() => _isLoadingAddress = true);
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse?lat=${pts.latitude}&lon=${pts.longitude}&format=json',
    );
    try {
      final res = await http.get(url, headers: {'User-Agent': 'HemisphereApp'});
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _currentAddress = data['display_name'];
          _searchC.text = _currentAddress ?? '';
          _searchResults.clear();
        });
      }
    } catch (_) {
    } finally {
      setState(() => _isLoadingAddress = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exact Location', style: AppTextStyles.labelLarge),
        actions: [
          if (_pickedLoc != null && _currentAddress != null)
            IconButton(
              icon: const Icon(Icons.check, color: AppColors.green),
              onPressed: () => Navigator.pop(
                context,
                _LocationResult(_pickedLoc!, _currentAddress!),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _pickedLoc!,
              initialZoom: 14.0,
              onTap: (tapPosition, point) {
                setState(() => _pickedLoc = point);
                _reverseGeocode(point);
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://api.mapbox.com/styles/v1/mapbox/streets-v12/tiles/256/{z}/{x}/{y}@2x?access_token={accessToken}',
                additionalOptions: {
                  'accessToken': dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '',
                },
                userAgentPackageName: 'com.hemisphere.app',
              ),
              if (_pickedLoc != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _pickedLoc!,
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.blue,
                        size: 40,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: context.h.surface, // Or Colors.white
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.black, width: 2),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 4),
                    ],
                  ),
                  child: TextField(
                    controller: _searchC,
                    onChanged: _onSearchChanged,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: context.h.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search landmark...',
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: context.h.textSecondary,
                      ),
                      prefixIcon: const Icon(Icons.search),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      suffixIcon: _isLoadingAddress
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(),
                            )
                          : IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchC.clear();
                                setState(() => _searchResults.clear());
                              },
                            ),
                    ),
                  ),
                ),
                if (_searchResults.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: context.h.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.black, width: 2),
                    ),
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _searchResults.length,
                      separatorBuilder: (c, i) =>
                          const Divider(height: 1, color: AppColors.black),
                      itemBuilder: (c, i) {
                        final res = _searchResults[i];
                        return ListTile(
                          title: Text(
                            res.displayName,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.black,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            setState(() {
                              _pickedLoc = res.coords;
                              _currentAddress = res.displayName;
                              _searchC.text = res.displayName;
                              _searchResults.clear();
                              _mapController.move(res.coords, 16.0);
                            });
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
