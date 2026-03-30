<<<<<<< HEAD
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../../theme/app_theme.dart';
import 'report_processing_screen.dart';

enum ReportType { accident, waste }

class ReportFormScreen extends StatefulWidget {
  final ReportType reportType;

  const ReportFormScreen({super.key, required this.reportType});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _descriptionController = TextEditingController();
  XFile? _capturedImage;
  Position? _currentPosition;
  bool _isFetchingLocation = false;
  bool _isSubmitting = false;

  bool get isAccident => widget.reportType == ReportType.accident;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _fetchLocation() async {
    setState(() => _isFetchingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied. Using default location.')),
          );
        }
        // Fallback to dummy position
        setState(() {
          _currentPosition = null;
          _isFetchingLocation = false;
        });
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      if (mounted) {
        setState(() {
          _currentPosition = position;
          _isFetchingLocation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isFetchingLocation = false);
      }
    }
  }

  Future<void> _captureImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      maxWidth: 1280,
    );
    if (image != null && mounted) {
      setState(() {
        _capturedImage = image;
      });
    }
  }



  Future<void> _submitReport() async {
    if (_capturedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please capture or upload a photo')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ReportProcessingScreen(
            reportType: widget.reportType,
            imagePath: _capturedImage!.path,
            latitude: _currentPosition?.latitude ?? 12.9716,
            longitude: _currentPosition?.longitude ?? 77.5946,
            description: _descriptionController.text,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isAccident ? 'Report Accident' : 'Report Waste'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Alert banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: (isAccident ? AppColors.red : AppColors.yellow)
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: (isAccident ? AppColors.red : AppColors.yellow)
                      .withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isAccident
                        ? Icons.emergency_rounded
                        : Icons.eco_rounded,
                    color: isAccident ? AppColors.red : AppColors.yellow,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isAccident
                          ? 'This report will be forwarded to emergency services and nearby hospitals.'
                          : 'This report will alert the municipal cleaning staff for immediate action.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: context.h.textTertiary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Camera section
            Text('Capture Evidence', style: AppTextStyles.headlineSmall.copyWith(color: context.h.textPrimary)),
            const SizedBox(height: 12),
            if (_capturedImage != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    Image.file(
                      File(_capturedImage!.path),
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => setState(() => _capturedImage = null),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.black.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, color: AppColors.white, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              GestureDetector(
                onTap: _captureImage,
                child: Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    color: context.h.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.h.divider, width: 1.5),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.yellow.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: AppColors.yellow,
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text('Tap to Open Camera', style: AppTextStyles.labelLarge.copyWith(color: context.h.textPrimary)),
                      const SizedBox(height: 4),
                      Text('Take a photo of the situation',
                          style: AppTextStyles.caption.copyWith(color: context.h.textCaption)),
                    ],
                  ),
                ),
              ),
            ],
            // Location section
            Text('Location', style: AppTextStyles.headlineSmall.copyWith(color: context.h.textPrimary)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.h.card,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.green.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _isFetchingLocation
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.green,
                            ),
                          )
                        : const Icon(Icons.gps_fixed_rounded,
                            color: AppColors.green, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isFetchingLocation
                              ? 'Fetching GPS coordinates...'
                              : 'Location Acquired',
                          style: AppTextStyles.labelLarge.copyWith(fontSize: 13, color: context.h.textPrimary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _currentPosition != null
                              ? '${_currentPosition!.latitude.toStringAsFixed(6)}, ${_currentPosition!.longitude.toStringAsFixed(6)}'
                              : _isFetchingLocation
                                  ? 'High accuracy mode'
                                  : '12.971600, 77.594600 (default)',
                          style: AppTextStyles.caption.copyWith(color: context.h.textCaption),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: AppColors.grey400),
                    onPressed: _fetchLocation,
                    tooltip: 'Refresh location',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Description
            Text('Description (Optional)', style: AppTextStyles.headlineSmall.copyWith(color: context.h.textPrimary)),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              style: AppTextStyles.bodyMedium.copyWith(color: context.h.textPrimary),
              decoration: InputDecoration(
                hintText: isAccident
                    ? 'Describe the accident: vehicles involved, injuries, road condition...'
                    : 'Describe the waste issue: type of waste, size of dump, urgency...',
              ),
            ),
            const SizedBox(height: 32),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isAccident ? AppColors.red : AppColors.yellow,
                  foregroundColor: isAccident ? AppColors.white : AppColors.black,
                  textStyle: AppTextStyles.buttonLarge,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isSubmitting
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: isAccident ? AppColors.white : AppColors.black,
                        ),
                      )
                    : Text(isAccident ? 'Submit Emergency Report' : 'Submit Waste Report'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
=======
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../../theme/app_theme.dart';
import 'report_processing_screen.dart';

enum ReportType { accident, waste }

class ReportFormScreen extends StatefulWidget {
  final ReportType reportType;

  const ReportFormScreen({super.key, required this.reportType});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _descriptionController = TextEditingController();
  XFile? _capturedImage;
  Position? _currentPosition;
  bool _isFetchingLocation = false;
  bool _isSubmitting = false;

  bool get isAccident => widget.reportType == ReportType.accident;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _fetchLocation() async {
    setState(() => _isFetchingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied. Using default location.')),
          );
        }
        // Fallback to dummy position
        setState(() {
          _currentPosition = null;
          _isFetchingLocation = false;
        });
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      if (mounted) {
        setState(() {
          _currentPosition = position;
          _isFetchingLocation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isFetchingLocation = false);
      }
    }
  }

  Future<void> _captureImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      maxWidth: 1280,
    );
    if (image != null && mounted) {
      setState(() {
        _capturedImage = image;
      });
    }
  }



  Future<void> _submitReport() async {
    if (_capturedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please capture or upload a photo')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ReportProcessingScreen(
            reportType: widget.reportType,
            imagePath: _capturedImage!.path,
            latitude: _currentPosition?.latitude ?? 12.9716,
            longitude: _currentPosition?.longitude ?? 77.5946,
            description: _descriptionController.text,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isAccident ? 'Report Accident' : 'Report Waste'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Alert banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: (isAccident ? AppColors.red : AppColors.yellow)
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: (isAccident ? AppColors.red : AppColors.yellow)
                      .withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isAccident
                        ? Icons.emergency_rounded
                        : Icons.eco_rounded,
                    color: isAccident ? AppColors.red : AppColors.yellow,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isAccident
                          ? 'This report will be forwarded to emergency services and nearby hospitals.'
                          : 'This report will alert the municipal cleaning staff for immediate action.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: context.h.textTertiary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Camera section
            Text('Capture Evidence', style: AppTextStyles.headlineSmall.copyWith(color: context.h.textPrimary)),
            const SizedBox(height: 12),
            if (_capturedImage != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    Image.file(
                      File(_capturedImage!.path),
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => setState(() => _capturedImage = null),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.black.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, color: AppColors.white, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              GestureDetector(
                onTap: _captureImage,
                child: Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    color: context.h.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.h.divider, width: 1.5),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.yellow.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: AppColors.yellow,
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text('Tap to Open Camera', style: AppTextStyles.labelLarge.copyWith(color: context.h.textPrimary)),
                      const SizedBox(height: 4),
                      Text('Take a photo of the situation',
                          style: AppTextStyles.caption.copyWith(color: context.h.textCaption)),
                    ],
                  ),
                ),
              ),
            ],
            // Location section
            Text('Location', style: AppTextStyles.headlineSmall.copyWith(color: context.h.textPrimary)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.h.card,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.green.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _isFetchingLocation
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.green,
                            ),
                          )
                        : const Icon(Icons.gps_fixed_rounded,
                            color: AppColors.green, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isFetchingLocation
                              ? 'Fetching GPS coordinates...'
                              : 'Location Acquired',
                          style: AppTextStyles.labelLarge.copyWith(fontSize: 13, color: context.h.textPrimary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _currentPosition != null
                              ? '${_currentPosition!.latitude.toStringAsFixed(6)}, ${_currentPosition!.longitude.toStringAsFixed(6)}'
                              : _isFetchingLocation
                                  ? 'High accuracy mode'
                                  : '12.971600, 77.594600 (default)',
                          style: AppTextStyles.caption.copyWith(color: context.h.textCaption),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: AppColors.grey400),
                    onPressed: _fetchLocation,
                    tooltip: 'Refresh location',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Description
            Text('Description (Optional)', style: AppTextStyles.headlineSmall.copyWith(color: context.h.textPrimary)),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              style: AppTextStyles.bodyMedium.copyWith(color: context.h.textPrimary),
              decoration: InputDecoration(
                hintText: isAccident
                    ? 'Describe the accident: vehicles involved, injuries, road condition...'
                    : 'Describe the waste issue: type of waste, size of dump, urgency...',
              ),
            ),
            const SizedBox(height: 32),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isAccident ? AppColors.red : AppColors.yellow,
                  foregroundColor: isAccident ? AppColors.white : AppColors.black,
                  textStyle: AppTextStyles.buttonLarge,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isSubmitting
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: isAccident ? AppColors.white : AppColors.black,
                        ),
                      )
                    : Text(isAccident ? 'Submit Emergency Report' : 'Submit Waste Report'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
>>>>>>> 345e37f98aab254ec09547299a58d8adbac3233b
