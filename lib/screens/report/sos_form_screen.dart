import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import '../../services/firestore_service.dart';

class SosFormScreen extends StatefulWidget {
  const SosFormScreen({super.key});

  @override
  State<SosFormScreen> createState() => _SosFormScreenState();
}

class _SosFormScreenState extends State<SosFormScreen> {
  final _descriptionController = TextEditingController();
  Position? _currentPosition;
  bool _isFetchingLocation = false;
  bool _isSubmitting = false;

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
            const SnackBar(content: Text('Location permission denied. SOS requires location.')),
          );
        }
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

  Future<void> _sendSos() async {
    if (_isSubmitting) return;

    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please wait for location to load.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final profile = await FirestoreService.instance.getProfile();
      final String emergencyContact = profile?['emergencyContact'] ?? '';

      if (emergencyContact.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Emergency Contact is not set! Please set it in your Profile.'),
            duration: Duration(seconds: 4),
          ),
        );
        setState(() => _isSubmitting = false);
        return;
      }

      final desc = _descriptionController.text.trim();
      final mapLink = "https://maps.google.com/?q=${_currentPosition!.latitude},${_currentPosition!.longitude}";
      final body = "SOS Emergency! My location: $mapLink\n\n${desc.isNotEmpty ? 'Details: $desc' : ''}";
      
      final url = Uri.parse("sms:$emergencyContact?body=${Uri.encodeComponent(body)}");
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Open SMS App to proceed...')),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open SMS app on your device.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending SOS: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send SOS Signal'),
        backgroundColor: AppColors.red,
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
                color: AppColors.red,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.black, width: 2),
                boxShadow: const [
                  BoxShadow(color: AppColors.black, blurRadius: 0, offset: Offset(2, 2)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.black, width: 2),
                      boxShadow: const [
                        BoxShadow(color: AppColors.black, blurRadius: 0, offset: Offset(2, 2)),
                      ],
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.black,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'This will send an emergency SOS SMS to your specified emergency contact with your live location coordinates.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.black,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Location section
            Text('Location', style: AppTextStyles.headlineSmall.copyWith(color: context.h.textPrimary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.h.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.black, width: 2),
                boxShadow: const [
                  BoxShadow(color: AppColors.black, blurRadius: 0, offset: Offset(2, 2)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.red,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.black, width: 2),
                      boxShadow: const [
                        BoxShadow(color: AppColors.black, blurRadius: 0, offset: Offset(2, 2)),
                      ],
                    ),
                    child: _isFetchingLocation
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.black,
                            ),
                          )
                        : const Icon(Icons.gps_fixed_rounded, color: AppColors.black, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentPosition != null ? 'Location Attached' : (_isFetchingLocation ? 'Fetching...' : 'Location Pending'),
                          style: AppTextStyles.bodyMedium.copyWith(color: context.h.textPrimary, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _currentPosition != null
                              ? '${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}'
                              : 'Waiting for coordinates',
                          style: AppTextStyles.caption.copyWith(color: context.h.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Details section
            Text('Emergency Details', style: AppTextStyles.headlineSmall.copyWith(color: context.h.textPrimary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.black, width: 2),
                boxShadow: const [
                  BoxShadow(color: AppColors.black, blurRadius: 0, offset: Offset(4, 4)),
                ],
              ),
              child: TextField(
                controller: _descriptionController,
                maxLines: 4,
                style: AppTextStyles.bodyMedium.copyWith(color: context.h.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Any extra details? (e.g. My car broke down, I feel unsafe)',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(color: context.h.textSecondary),
                  filled: true,
                  fillColor: context.h.card,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
        decoration: BoxDecoration(
          color: context.h.surface,
          border: const Border(top: BorderSide(color: AppColors.black, width: 2)),
        ),
        child: GestureDetector(
          onTap: _isSubmitting || _currentPosition == null ? null : _sendSos,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 56,
            decoration: BoxDecoration(
              color: (_isSubmitting || _currentPosition == null) ? AppColors.red.withValues(alpha: 0.5) : AppColors.red,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.black, width: 2),
              boxShadow: (_isSubmitting || _currentPosition == null)
                  ? []
                  : const [
                      BoxShadow(
                        color: AppColors.black,
                        blurRadius: 0,
                        offset: Offset(4, 4),
                      )
                    ],
            ),
            child: Center(
              child: _isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: AppColors.black, strokeWidth: 3),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.send_rounded, color: AppColors.black),
                        const SizedBox(width: 8),
                        Text(
                          'SEND SOS SIGNAL',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.black,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
