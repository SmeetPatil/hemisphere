import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/community_event.dart';
import '../../models/resource_listing.dart';
import '../../providers/map_provider.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/event_card.dart';
import '../../widgets/resource_card.dart';
import 'chat_screen.dart';
import 'package:geolocator/geolocator.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool _showComposer = false;
  int _composerType = 0;

  final _eventTitleController = TextEditingController();
  final _eventDescController = TextEditingController();
  final _eventLocationController = TextEditingController();
  final _eventCategoryController = TextEditingController(text: 'Social');
  final _eventMaxAttendeesController = TextEditingController(text: '20');

  final _resourceTitleController = TextEditingController();
  final _resourceDescController = TextEditingController();

  final _hobbyTitleController = TextEditingController();
  final _hobbyDescController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);

  String get _currentUserName =>
      FirebaseAuth.instance.currentUser?.displayName ??
      FirebaseAuth.instance.currentUser?.email?.split('@').first ??
      'User';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this)
      ..addListener(() {
        if (!_tabController.indexIsChanging) {
          setState(() => _composerType = _tabController.index);
        }
      });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _eventTitleController.dispose();
    _eventDescController.dispose();
    _eventLocationController.dispose();
    _eventCategoryController.dispose();
    _eventMaxAttendeesController.dispose();
    _resourceTitleController.dispose();
    _resourceDescController.dispose();
    _hobbyTitleController.dispose();
    _hobbyDescController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time != null) setState(() => _selectedTime = time);
  }

  Future<void> _submitComposer() async {
    Position? currentPos;
    try {
      if (await Geolocator.isLocationServiceEnabled()) {
        LocationPermission perm = await Geolocator.checkPermission();
        if (perm == LocationPermission.denied) {
          perm = await Geolocator.requestPermission();
        }
        if (perm == LocationPermission.whileInUse || perm == LocationPermission.always) {
          currentPos = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
          );
        }
      }
    } catch (_) {
      // Ignored: If location times out or can't be fetched, we proceed without coordinates
    }

    if (_composerType == 0) {
      if (_eventTitleController.text.trim().isEmpty ||
          _eventDescController.text.trim().isEmpty ||
          _eventLocationController.text.trim().isEmpty) {
        _showSnack('Please fill event title, details, and location.');
        return;
      }

      final eventDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final event = CommunityEvent(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _eventTitleController.text.trim(),
        description: _eventDescController.text.trim(),
        organizer: _currentUserName,
        dateTime: eventDateTime,
        location: _eventLocationController.text.trim(),
        category: _eventCategoryController.text.trim().isEmpty
            ? 'Social'
            : _eventCategoryController.text.trim(),
        attendees: 1,
        maxAttendees: int.tryParse(_eventMaxAttendeesController.text) ?? 20,
        latitude: currentPos?.latitude,
        longitude: currentPos?.longitude,
      );

      await FirestoreService.instance.addEvent(event);
      _eventTitleController.clear();
      _eventDescController.clear();
      _eventLocationController.clear();
      _eventCategoryController.text = 'Social';
      _eventMaxAttendeesController.text = '20';
      _showSnack('Event hosted successfully.');
    } else if (_composerType == 1) {
      if (_resourceTitleController.text.trim().isEmpty ||
          _resourceDescController.text.trim().isEmpty) {
        _showSnack('Please add resource title and details.');
        return;
      }

      final resource = ResourceListing(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _resourceTitleController.text.trim(),
        description: _resourceDescController.text.trim(),
        ownerName: _currentUserName,
        ownerAvatar: _avatarFromName(_currentUserName),
        category: ResourceCategory.tools,
        isAvailable: true,
        postedAt: DateTime.now(),
        latitude: currentPos?.latitude,
        longitude: currentPos?.longitude,
      );

      await FirestoreService.instance.addResource(resource);
      _resourceTitleController.clear();
      _resourceDescController.clear();
      _showSnack('Resource shared successfully.');
    } else {
      if (_hobbyTitleController.text.trim().isEmpty ||
          _hobbyDescController.text.trim().isEmpty) {
        _showSnack('Please add hobby title and details.');
        return;
      }

      final hobby = ResourceListing(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _hobbyTitleController.text.trim(),
        description: _hobbyDescController.text.trim(),
        ownerName: _currentUserName,
        ownerAvatar: _avatarFromName(_currentUserName),
        category: ResourceCategory.hobbies,
        isAvailable: true,
        postedAt: DateTime.now(),
        latitude: currentPos?.latitude,
        longitude: currentPos?.longitude,
      );

      await FirestoreService.instance.addResource(hobby);
      _hobbyTitleController.clear();
      _hobbyDescController.clear();
      _showSnack('Hobby shared successfully.');
    }

    _tabController.animateTo(_composerType);
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _avatarFromName(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  void _openChatWith(String personName, {String? relatedListingId}) async {
    final chatId = await FirestoreService.instance
        .getOrCreateChat(personName, relatedListingId: relatedListingId);
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ChatScreen(chatId: chatId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Community',
                        style: AppTextStyles.displayLarge
                            .copyWith(color: context.h.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Connect, share, and grow together',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: context.h.textSecondary),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _showComposer = !_showComposer),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.yellow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _showComposer
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.add_rounded,
                      color: AppColors.black,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: context.h.card,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: context.h.cardShadow,
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.yellow,
                borderRadius: BorderRadius.circular(12),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: AppColors.black,
              unselectedLabelColor: context.h.textCaption,
              labelStyle: AppTextStyles.labelLarge.copyWith(fontSize: 13),
              unselectedLabelStyle: AppTextStyles.labelMedium,
              dividerColor: Colors.transparent,
              padding: const EdgeInsets.all(4),
              tabs: const [
                Tab(text: 'Events'),
                Tab(text: 'Resources'),
                Tab(text: 'Hobbies'),
              ],
            ),
          ),

          if (_showComposer)
            Container(
              margin: const EdgeInsets.fromLTRB(20, 14, 20, 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.h.card,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: context.h.cardShadow,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create in community',
                    style: AppTextStyles.labelLarge
                        .copyWith(color: context.h.textPrimary),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _ComposerTypeChip(
                        label: 'Host Event',
                        isActive: _composerType == 0,
                        onTap: () => setState(() => _composerType = 0),
                      ),
                      const SizedBox(width: 8),
                      _ComposerTypeChip(
                        label: 'Share Resource',
                        isActive: _composerType == 1,
                        onTap: () => setState(() => _composerType = 1),
                      ),
                      const SizedBox(width: 8),
                      _ComposerTypeChip(
                        label: 'Share Hobby',
                        isActive: _composerType == 2,
                        onTap: () => setState(() => _composerType = 2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_composerType == 0) ...[
                    _CommunityInput(controller: _eventTitleController, hint: 'Event title'),
                    const SizedBox(height: 8),
                    _CommunityInput(controller: _eventDescController, hint: 'Event details', maxLines: 2),
                    const SizedBox(height: 8),
                    _CommunityInput(controller: _eventLocationController, hint: 'Location'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: _CommunityInput(controller: _eventCategoryController, hint: 'Category')),
                        const SizedBox(width: 8),
                        Expanded(child: _CommunityInput(controller: _eventMaxAttendeesController, hint: 'Max people', keyboardType: TextInputType.number)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickDate,
                            icon: const Icon(Icons.calendar_today_rounded, size: 16),
                            label: Text(DateFormat('d MMM yyyy').format(_selectedDate)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickTime,
                            icon: const Icon(Icons.access_time_rounded, size: 16),
                            label: Text(_selectedTime.format(context)),
                          ),
                        ),
                      ],
                    ),
                  ] else if (_composerType == 1) ...[
                    _CommunityInput(controller: _resourceTitleController, hint: 'Resource title'),
                    const SizedBox(height: 8),
                    _CommunityInput(controller: _resourceDescController, hint: 'What are you sharing?', maxLines: 2),
                  ] else ...[
                    _CommunityInput(controller: _hobbyTitleController, hint: 'Hobby title'),
                    const SizedBox(height: 8),
                    _CommunityInput(controller: _hobbyDescController, hint: 'Tell neighbors about your hobby', maxLines: 2),
                  ],
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _submitComposer,
                      icon: const Icon(Icons.send_rounded),
                      label: Text(
                        _composerType == 0
                            ? 'Host Event'
                            : _composerType == 1
                                ? 'Share Resource'
                                : 'Share Hobby',
                      ),
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _EventsTab(
                  extraTopPadding: _showComposer ? 0 : 8,
                  onMessageTap: (name, id) =>
                      _openChatWith(name, relatedListingId: id),
                ),
                _ResourcesTab(
                  extraTopPadding: _showComposer ? 0 : 8,
                  onMessageTap: (name, id) =>
                      _openChatWith(name, relatedListingId: id),
                ),
                _HobbiesTab(
                  extraTopPadding: _showComposer ? 0 : 8,
                  onMessageTap: (name, id) =>
                      _openChatWith(name, relatedListingId: id),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tabs — now use Firestore streams
// ---------------------------------------------------------------------------

class _EventsTab extends StatelessWidget {
  final double extraTopPadding;
  final void Function(String personName, String relatedId) onMessageTap;

  const _EventsTab({required this.extraTopPadding, required this.onMessageTap});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CommunityEvent>>(
      stream: FirestoreService.instance.eventsStream(
          neighborhoodId: MapProvider.instance.currentNeighborhoodId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.yellow));
        }
        final events = snapshot.data ?? [];
        if (events.isEmpty) {
          return Center(
            child: Text('No events yet. Host one above.',
                style: AppTextStyles.bodyMedium.copyWith(color: context.h.textSecondary)),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.fromLTRB(20, extraTopPadding, 20, 18),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return Column(
              children: [
                EventCard(
                  event: event,
                  isJoined: false,
                  messageText: 'Message ${event.organizer}',
                  onMessageTap: () => onMessageTap(event.organizer, event.id),
                  onJoin: () async {
                    await FirestoreService.instance.toggleEventJoin(event.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Toggled join for "${event.title}"')),
                      );
                    }
                  },
                ),
                const SizedBox(height: 12),
              ],
            );
          },
        );
      },
    );
  }
}

class _ResourcesTab extends StatelessWidget {
  final double extraTopPadding;
  final void Function(String personName, String relatedId) onMessageTap;

  const _ResourcesTab({required this.extraTopPadding, required this.onMessageTap});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ResourceListing>>(
      stream: FirestoreService.instance.resourcesStream(
          hobbiesOnly: false,
          neighborhoodId: MapProvider.instance.currentNeighborhoodId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.yellow));
        }
        final resources = snapshot.data ?? [];
        if (resources.isEmpty) {
          return Center(
            child: Text('No resources shared yet.',
                style: AppTextStyles.bodyMedium.copyWith(color: context.h.textSecondary)),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.fromLTRB(20, extraTopPadding, 20, 18),
          itemCount: resources.length,
          itemBuilder: (context, index) {
            final resource = resources[index];
            return Column(
              children: [
                ResourceCard(resource: resource),
                _MessageBox(
                  text: 'Message ${resource.ownerName}',
                  onTap: () => onMessageTap(resource.ownerName, resource.id),
                ),
                const SizedBox(height: 12),
              ],
            );
          },
        );
      },
    );
  }
}

class _HobbiesTab extends StatelessWidget {
  final double extraTopPadding;
  final void Function(String personName, String relatedId) onMessageTap;

  const _HobbiesTab({required this.extraTopPadding, required this.onMessageTap});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ResourceListing>>(
      stream: FirestoreService.instance.resourcesStream(
          hobbiesOnly: true,
          neighborhoodId: MapProvider.instance.currentNeighborhoodId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.yellow));
        }
        final hobbies = snapshot.data ?? [];
        if (hobbies.isEmpty) {
          return Center(
            child: Text('No hobbies shared yet.',
                style: AppTextStyles.bodyMedium.copyWith(color: context.h.textSecondary)),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.fromLTRB(20, extraTopPadding, 20, 18),
          itemCount: hobbies.length,
          itemBuilder: (context, index) {
            final hobby = hobbies[index];
            return Column(
              children: [
                ResourceCard(resource: hobby),
                _MessageBox(
                  text: 'Message ${hobby.ownerName}',
                  onTap: () => onMessageTap(hobby.ownerName, hobby.id),
                ),
                const SizedBox(height: 12),
              ],
            );
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Shared widgets (unchanged)
// ---------------------------------------------------------------------------
class _ComposerTypeChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ComposerTypeChip({required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? AppColors.yellow : context.h.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isActive ? AppColors.yellow : context.h.divider),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(
              color: isActive ? AppColors.black : context.h.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _CommunityInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;

  const _CommunityInput({required this.controller, required this.hint, this.maxLines = 1, this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: AppTextStyles.bodyMedium.copyWith(color: context.h.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        filled: true,
        fillColor: context.h.inputFill,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}

class _MessageBox extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _MessageBox({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: context.h.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.h.divider),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 44, // Increased height to prevent cutoff
        child: ElevatedButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.chat_rounded, size: 18),
          label: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            backgroundColor: AppColors.yellow,
            foregroundColor: AppColors.black,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            textStyle: AppTextStyles.caption.copyWith(color: AppColors.black, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
