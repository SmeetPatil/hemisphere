import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../models/community_event.dart';
import '../../models/resource_listing.dart';
import '../../services/firestore_service.dart';

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
        border: Border.all(color: AppColors.black, width: 2), // Heavy black border
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
          hintStyle:
              AppTextStyles.bodyMedium.copyWith(color: context.h.textCaption),
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
                BoxShadow(color: AppColors.black, offset: Offset(4, 4), blurRadius: 0),
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
        _CustomTextField(controller: _titleC, hintText: 'Event Title (What is happening?)', icon: Icons.title_rounded),
        const SizedBox(height: 16),
        _CustomTextField(controller: _locC, hintText: 'Location (Where is it?)', icon: Icons.location_on_rounded),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _CustomTextField(
                controller: TextEditingController(
                  text: '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
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
                controller: TextEditingController(text: _selectedTime.format(context)),
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
            Expanded(child: _CustomTextField(controller: _categoryC, hintText: 'Category (e.g. Social, Tech)', icon: Icons.category_rounded)),
            const SizedBox(width: 16),
            Expanded(child: _CustomTextField(controller: _attendeesC, hintText: 'Max People (e.g. 20)', icon: Icons.people_rounded, keyboardType: TextInputType.number)),
          ],
        ),
        const SizedBox(height: 16),
        _CustomTextField(controller: _descC, maxLines: 4, hintText: 'Description (Provide details about the event)'),
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
          child: Text('Create Event', style: AppTextStyles.labelLarge.copyWith(color: AppColors.black, fontWeight: FontWeight.w800)),
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

  String get _currentUserName =>
      FirebaseAuth.instance.currentUser?.displayName ??
      FirebaseAuth.instance.currentUser?.email?.split('@').first ??
      'User';

  Future<void> _submit() async {
    if (_titleC.text.isEmpty || _descC.text.isEmpty) return;

    final newRes = ResourceListing(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleC.text,
      description: _descC.text,
      ownerName: _currentUserName,
      ownerAvatar: 'ME',
      category: widget.isHobby ? ResourceCategory.hobbies : ResourceCategory.tools,
      isAvailable: true,
      postedAt: DateTime.now(),
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
          hintText: widget.isHobby ? 'Hobby Title (e.g. Weekend Cycling)' : 'Resource Title (e.g. Power Drill)',
          icon: widget.isHobby ? Icons.sports_tennis_rounded : Icons.build_rounded,
        ),
        const SizedBox(height: 16),
        _CustomTextField(
          controller: _descC,
          maxLines: 4,
          hintText: widget.isHobby ? 'Description (Tell us about your hobby)' : 'Description (Describe the resource you are sharing)',
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
            style: AppTextStyles.labelLarge.copyWith(color: AppColors.black, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}
