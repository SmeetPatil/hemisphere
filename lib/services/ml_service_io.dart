import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class MLService {
  Interpreter? _safetyInterpreter;
  Interpreter? _garbageInterpreter;
  Interpreter? _emissionsInterpreter;

  final List<String> _safetyClasses = ['accident', 'construction', 'normal'];
  final List<String> _garbageClasses = ['clean', 'garbage'];

  Future<void> init() async {
    try {
      _safetyInterpreter =
          await Interpreter.fromAsset('assets/models/safety_model.tflite');
      _garbageInterpreter = await Interpreter.fromAsset(
        'assets/models/garbage_classification_model.tflite',
      );
      _emissionsInterpreter = await Interpreter.fromAsset(
        'assets/models/emissions_model.tflite',
      );
    } catch (_) {
      // Keep null interpreters and return fallback labels in predict methods.
    }
  }

  Future<String?> predictSafety(File imageFile) async {
    if (_safetyInterpreter == null) {
      return 'Model not loaded';
    }

    try {
      final input = _preProcessImage(imageFile);
      final output = List.filled(1 * 3, 0.0).reshape([1, 3]);
      _safetyInterpreter!.run(input, output);
      return _getLabel(output[0], _safetyClasses);
    } catch (_) {
      return 'Prediction failed';
    }
  }

  Future<String?> predictGarbage(File imageFile) async {
    if (_garbageInterpreter == null) {
      return 'Model not loaded';
    }

    try {
      final input = _preProcessImage(imageFile);
      final output = List.filled(1 * 2, 0.0).reshape([1, 2]);
      _garbageInterpreter!.run(input, output);
      return _getLabel(output[0], _garbageClasses);
    } catch (_) {
      return 'Prediction failed';
    }
  }

  Future<double?> predictEmissions(
      double engineSizeL, int cylinders, int fuelType, double daysUsed, double hoursPerDay) async {
    if (_emissionsInterpreter == null) {
      return null;
    }

    try {
      // Normalization constants from training parameters
      const double meanEngine = 3.1651;
      const double stdEngine = 1.3593;
      const double meanCylinders = 5.6234;
      const double stdCylinders = 1.8341;

      // Normalize continuous features
      final normalizedEngine = (engineSizeL - meanEngine) / stdEngine;
      final normalizedCyl = (cylinders - meanCylinders) / stdCylinders;

      // Create input tensor [1, 3]
      // Features: Engine Size, Cylinders, Fuel Type
      final input = [
        [normalizedEngine, normalizedCyl, fuelType.toDouble()]
      ];

      // Assuming model outputs a single continuous value [1, 1]
      final output = List.filled(1 * 1, 0.0).reshape([1, 1]);
      
      _emissionsInterpreter!.run(input, output);
      
      final double co2PerKm = output[0][0];
      
      // Calculate total emissions based on hours and days
      // Assuming avg speed of 30 km/h in neighborhood/city conditions
      const double avgSpeedKmh = 30.0;
      final double totalDistanceKm = daysUsed * hoursPerDay * avgSpeedKmh;
      final double totalEmissionGrams = co2PerKm * totalDistanceKm;
      
      return totalEmissionGrams;
    } catch (e) {
      print('Emissions prediction error: \$e');
      return null;
    }
  }

  List<List<List<List<double>>>> _preProcessImage(File imageFile) {
    final imageData = imageFile.readAsBytesSync();
    final originalImage = img.decodeImage(imageData);
    final image = img.copyResize(originalImage!, width: 224, height: 224);

    return List.generate(
      1,
      (i) => List.generate(
        224,
        (y) => List.generate(
          224,
          (x) {
            final pixel = image.getPixel(x, y);
            return [
              pixel.r / 255.0,
              pixel.g / 255.0,
              pixel.b / 255.0,
            ];
          },
        ),
      ),
    );
  }

  String _getLabel(
    List<double> probabilities,
    List<String> labels, {
    double threshold = 0.70,
  }) {
    var maxProb = double.negativeInfinity;
    var maxIndex = -1;

    for (var i = 0; i < probabilities.length; i++) {
      if (probabilities[i] > maxProb) {
        maxProb = probabilities[i];
        maxIndex = i;
      }
    }

    if (maxProb < threshold) {
      return 'Unrecognized';
    }

    return labels[maxIndex];
  }

  void dispose() {
    _safetyInterpreter?.close();
    _garbageInterpreter?.close();
    _emissionsInterpreter?.close();
  }
}
