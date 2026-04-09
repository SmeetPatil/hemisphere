import 'dart:io';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'report_form_screen.dart';
import 'report_confirmation_screen.dart'; // We can use or create a new result screen
import '../../services/ml_service.dart';
import '../../services/firestore_service.dart';
import '../../providers/map_provider.dart';
import '../../models/map_marker.dart';
import '../../models/feed_post.dart';
import 'package:latlong2/latlong.dart';

class ReportProcessingScreen extends StatefulWidget {
  final ReportType reportType;
  final String imagePath;
  final double latitude;
  final double longitude;
  final String description;

  const ReportProcessingScreen({
    super.key,
    required this.reportType,
    required this.imagePath,
    required this.latitude,
    required this.longitude,
    required this.description,
  });

  @override
  State<ReportProcessingScreen> createState() => _ReportProcessingScreenState();
}

class _ReportProcessingScreenState extends State<ReportProcessingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanningController;
  final MLService _mlService = MLService();
  String _statusMessage = 'Analyzing image...';

  @override
  void initState() {
    super.initState();
    _scanningController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _processReport();
  }

  @override
  void dispose() {
    _scanningController.dispose();
    _mlService.dispose();
    super.dispose();
  }

  Future<void> _processReport() async {
    await _mlService.init();
    
    // Simulate initial delay to show animation
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _statusMessage = 'Classifying scenario...';
    });
    
    String? result;
    if (widget.reportType == ReportType.accident) {
      result = await _mlService.predictSafety(File(widget.imagePath));
    } else {
      result = await _mlService.predictGarbage(File(widget.imagePath));
    }

    String finalResult = result?.toLowerCase() ?? 'unrecognized';

    final formattedResult = finalResult.substring(0, 1).toUpperCase() + finalResult.substring(1);
    
    // Wait a brief moment to show classification result
    setState(() {
      _statusMessage = 'Classification Complete!\nDetected: $formattedResult';
    });
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    // Handle different classification outcomes
    bool isNormal = (widget.reportType == ReportType.accident && finalResult == 'normal') || 
                   (widget.reportType == ReportType.waste && finalResult == 'clean') ||
                   (finalResult == 'unrecognized');

    if (isNormal) {
      String message = widget.reportType == ReportType.accident 
        ? "The image appears to show a normal road. Nothing has been reported."
        : "The street appears to be clean. Nothing has been reported.";
      if (finalResult == 'unrecognized') {
        message = "We couldn't clearly identify the issue in the image. No report was submitted.";
      }
      _showResultDialog("No Issue Detected", message, false);
      return;
    }

    // Add to dummy data map and feed
    _publishDummyData(finalResult);

    // Navigate to confirmation with specific behavior
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ReportConfirmationScreen(
          reportType: widget.reportType,
          latitude: widget.latitude,
          longitude: widget.longitude,
          detectedClass: finalResult,
        ),
      ),
    );
  }

  Future<void> _publishDummyData(String result) async {
    final neighborhoodId = MapProvider.instance.currentNeighborhoodId;

    if (widget.reportType == ReportType.accident) {
      if (result == 'accident') {
        await FirestoreService.instance.addReportAndFeed(
          neighborhoodId: neighborhoodId,
          markerData: MapMarkerData(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: 'Accident Reported',
            description: widget.description.isNotEmpty ? widget.description : 'Accident near your location. Emergency services alerted.',
            position: LatLng(widget.latitude, widget.longitude),
            type: MarkerType.accident,
            timestamp: DateTime.now(),
            reportedBy: 'You',
          ),
          feedData: FeedPost(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            authorName: 'System Alert',
            authorAvatar: 'SA',
            content: 'Accident reported at coordinates (${widget.latitude.toStringAsFixed(4)}, ${widget.longitude.toStringAsFixed(4)}). Emergency services and nearby hospitals have been notified. Please avoid this route if possible.',
            type: PostType.alert,
            timestamp: DateTime.now(),
            likes: 0,
            comments: 0,
          ),
        );
      } else if (result == 'construction') {
        await FirestoreService.instance.addReportAndFeed(
          neighborhoodId: neighborhoodId,
          markerData: MapMarkerData(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: 'Construction Ongoing',
            description: widget.description.isNotEmpty ? widget.description : 'Construction work. Alternative routes suggested.',
            position: LatLng(widget.latitude, widget.longitude),
            type: MarkerType.roadConstruction,
            timestamp: DateTime.now(),
            reportedBy: 'You',
          ),
          feedData: FeedPost(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            authorName: 'System Alert',
            authorAvatar: 'SA',
            content: 'Construction work detected at (${widget.latitude.toStringAsFixed(4)}, ${widget.longitude.toStringAsFixed(4)}). Alternative route suggestion activated to reduce neighborhood traffic.',
            type: PostType.alert,
            timestamp: DateTime.now(),
            likes: 0,
            comments: 0,
          ),
        );
      }
    } else if (widget.reportType == ReportType.waste) {
      if (result == 'garbage') {
        await FirestoreService.instance.addReportAndFeed(
          neighborhoodId: neighborhoodId,
          markerData: MapMarkerData(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: 'Waste Dump Reported',
            description: widget.description.isNotEmpty ? widget.description : 'Solid waste recorded. BMC notified.',
            position: LatLng(widget.latitude, widget.longitude),
            type: MarkerType.wasteCollection,
            timestamp: DateTime.now(),
            reportedBy: 'You',
          ),
          feedData: FeedPost(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            authorName: 'System Alert',
            authorAvatar: 'SA',
            content: 'Garbage dump reported and geotagged at (${widget.latitude.toStringAsFixed(4)}, ${widget.longitude.toStringAsFixed(4)}). A cleanup request has been sent to the municipality (BMC).',
            type: PostType.news,
            timestamp: DateTime.now(),
            likes: 0,
            comments: 0,
          ),
        );
      }
    }
  }

  void _showResultDialog(String title, String message, bool popTwice) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: AppTextStyles.headlineSmall.copyWith(color: context.h.textPrimary, fontWeight: FontWeight.bold)),
        content: Text(message, style: AppTextStyles.bodyMedium.copyWith(color: context.h.textSecondary)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to form
            },
            child: const Text('OK', style: TextStyle(color: AppColors.green)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Processing Report',
                style: AppTextStyles.headlineLarge.copyWith(color: context.h.textPrimary, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              
              // Animated Image Preview
              Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.black, width: 4),
                  boxShadow: const [
                    BoxShadow(color: AppColors.black, blurRadius: 0, offset: Offset(6, 6)),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Image.file(
                        File(widget.imagePath),
                        width: 260,
                        height: 260,
                        fit: BoxFit.cover,
                      ),
                      // Scanning line animation
                      AnimatedBuilder(
                        animation: _scanningController,
                        builder: (context, child) {
                          return Positioned(
                            top: _scanningController.value * 256,
                            child: Container(
                              width: 260,
                              height: 6,
                              decoration: BoxDecoration(
                                color: AppColors.green,
                                border: Border.all(color: AppColors.black, width: 1),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 48),
              
              const CircularProgressIndicator(color: AppColors.green, strokeWidth: 4),
              const SizedBox(height: 24),
              
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineSmall.copyWith(color: context.h.textPrimary, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
