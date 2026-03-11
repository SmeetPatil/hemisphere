import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class EventFormScreen extends StatefulWidget {
  const EventFormScreen({super.key});

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  final _maxAttendeesController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  String _selectedCategory = 'Social';

  final List<String> _categories = [
    'Social',
    'Health & Wellness',
    'Education',
    'Civic',
    'Market',
    'Sports',
    'Cultural',
    'Other',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    _maxAttendeesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: context.isDark
              ? ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: AppColors.yellow,
                    onPrimary: AppColors.black,
                    surface: AppColors.surfaceDark,
                    onSurface: AppColors.white,
                  ),
                )
              : ThemeData.light().copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: AppColors.yellow,
                    onPrimary: AppColors.black,
                  ),
                ),
          child: child!,
        );
      },
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: context.isDark
              ? ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: AppColors.yellow,
                    onPrimary: AppColors.black,
                    surface: AppColors.surfaceDark,
                    onSurface: AppColors.white,
                  ),
                )
              : ThemeData.light().copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: AppColors.yellow,
                    onPrimary: AppColors.black,
                  ),
                ),
          child: child!,
        );
      },
    );
    if (time != null) setState(() => _selectedTime = time);
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event created successfully!')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Host an Event'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Event Details', style: AppTextStyles.headlineMedium.copyWith(color: context.h.textPrimary)),
              const SizedBox(height: 20),

              // Title
              Text('Title', style: AppTextStyles.labelLarge.copyWith(color: context.h.textPrimary)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                style: AppTextStyles.bodyMedium.copyWith(color: context.h.textPrimary),
                decoration: const InputDecoration(hintText: 'e.g. Morning Yoga Session'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),

              // Description
              Text('Description', style: AppTextStyles.labelLarge.copyWith(color: context.h.textPrimary)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                style: AppTextStyles.bodyMedium.copyWith(color: context.h.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Tell people what to expect...',
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),

              // Category
              Text('Category', style: AppTextStyles.labelLarge.copyWith(color: context.h.textPrimary)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: context.h.inputFill,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    dropdownColor: context.h.card,
                    style: AppTextStyles.bodyMedium.copyWith(color: context.h.textPrimary),
                    items: _categories.map((c) {
                      return DropdownMenuItem(value: c, child: Text(c));
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedCategory = v);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Date & Time
              Text('Date & Time', style: AppTextStyles.labelLarge.copyWith(color: context.h.textPrimary)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: context.h.inputFill,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded,
                                size: 18, color: AppColors.yellow),
                            const SizedBox(width: 8),
                            Text(
                              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                              style: AppTextStyles.bodyMedium
                                  .copyWith(color: context.h.textPrimary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickTime,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: context.h.inputFill,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time_rounded,
                                size: 18, color: AppColors.yellow),
                            const SizedBox(width: 8),
                            Text(
                              _selectedTime.format(context),
                              style: AppTextStyles.bodyMedium
                                  .copyWith(color: context.h.textPrimary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Location
              Text('Location', style: AppTextStyles.labelLarge.copyWith(color: context.h.textPrimary)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _locationController,
                style: AppTextStyles.bodyMedium.copyWith(color: context.h.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'e.g. Community Hall, Block A',
                  prefixIcon: Icon(Icons.location_on_outlined,
                      color: AppColors.grey400),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),

              // Max attendees
              Text('Max Attendees', style: AppTextStyles.labelLarge.copyWith(color: context.h.textPrimary)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _maxAttendeesController,
                keyboardType: TextInputType.number,
                style: AppTextStyles.bodyMedium.copyWith(color: context.h.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'e.g. 30',
                  prefixIcon:
                      Icon(Icons.people_outline_rounded, color: AppColors.grey400),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 32),

              // Submit
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Create Event'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
