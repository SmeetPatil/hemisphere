import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class MLService {
  Interpreter? _safetyInterpreter;
  Interpreter? _garbageInterpreter;
  Interpreter? _emissionsInterpreterOriginal;
  Interpreter? _emissionsInterpreterNew;

  final List<String> _safetyClasses = ['accident', 'construction', 'normal'];
  final List<String> _garbageClasses = ['clean', 'garbage'];

  Future<void> init() async {
    try {
      _safetyInterpreter =
          await Interpreter.fromAsset('assets/models/safety_model.tflite');
      _garbageInterpreter = await Interpreter.fromAsset(
        'assets/models/garbage_classification_model.tflite',
      );
      _emissionsInterpreterOriginal = await Interpreter.fromAsset(
        'assets/models/emissions_model.tflite',
      );
      _emissionsInterpreterNew = await Interpreter.fromAsset(
        'assets/models/emissions_model_2.tflite',
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
      final input = await compute(_preProcessImageWorker, imageFile.path);
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
      final input = await compute(_preProcessImageWorker, imageFile.path);
      final output = List.filled(1 * 2, 0.0).reshape([1, 2]);
      _garbageInterpreter!.run(input, output);
      return _getLabel(output[0], _garbageClasses);
    } catch (_) {
      return 'Prediction failed';
    }
  }

Future<double?> predictEmissionsOriginal(
      double engineSizeL, int cylinders, int fuelType, double daysUsed, double hoursPerDay) async {
    if (_emissionsInterpreterOriginal == null) {
      return null;
    }

    try {
      const double meanEngine = 3.1651;
      const double stdEngine = 1.3593;
      const double meanCylinders = 5.6234;
      const double stdCylinders = 1.8341;

      final normalizedEngine = (engineSizeL - meanEngine) / stdEngine;
      final normalizedCyl = (cylinders - meanCylinders) / stdCylinders;

      final input = [
        [normalizedEngine, normalizedCyl, fuelType.toDouble()]
      ];

      final output = List.filled(1 * 1, 0.0).reshape([1, 1]);
      _emissionsInterpreterOriginal!.run(input, output);

      final double co2PerKm = output[0][0];

      const double avgSpeedKmh = 30.0;
      final double totalDistanceKm = daysUsed * hoursPerDay * avgSpeedKmh;
      return co2PerKm * totalDistanceKm;
    } catch (e) {
      print('Emissions prediction error (Original): \$e');
      return null;
    }
  }

  Future<double?> predictEmissionsHeuristic(
      double engineSizeL, int cylinders, int fuelType, int vehicleYear, double daysUsed, double hoursPerDay) async {
    final double? originalEmissions = await predictEmissionsOriginal(engineSizeL, cylinders, fuelType, daysUsed, hoursPerDay);
    if (originalEmissions == null) return null;

    // Apply a heuristic penalty: add 1% extra emissions for every year the car is older than 2024
    int currentYear = 2024;
    double agePenalty = 1.0;
    if (vehicleYear < currentYear) {
      agePenalty += (currentYear - vehicleYear) * 0.01;
    }
    
    return originalEmissions * agePenalty;
  }

  Future<double?> predictEmissionsNew(
      double engineSizeL, int vehicleAge, int fuelTypeNewVersion, double daysUsed, double hoursPerDay) async {
    if (_emissionsInterpreterNew == null) {
      return null;
    }

    try {
      // NEW MODEL: Engine Size, Age of Vehicle, Fuel Type.
      // Fuel Mapping: {'Electric': 0, 'Hybrid': 1, 'Petrol': 2, 'Diesel': 3}
      // Engine Size -> Mean: 3.3639, Std: 1.4967
      // Age of Vehicle -> Mean: 14.4819, Std: 8.6033
      
      const double meanEngine = 3.3639;
      const double stdEngine = 1.4967;
      const double meanAge = 14.4819;
      const double stdAge = 8.6033;

      final normalizedEngine = (engineSizeL - meanEngine) / stdEngine;
      final normalizedAge = (vehicleAge.toDouble() - meanAge) / stdAge;

      final input = [
        [normalizedEngine, normalizedAge, fuelTypeNewVersion.toDouble()]
      ];

      final output = List.filled(1 * 1, 0.0).reshape([1, 1]);
      _emissionsInterpreterNew!.run(input, output);

      final double co2PerKm = output[0][0];

      const double avgSpeedKmh = 30.0;
      final double totalDistanceKm = daysUsed * hoursPerDay * avgSpeedKmh;
      return co2PerKm * totalDistanceKm;
    } catch (e) {
      print('Emissions prediction error (New): \$e');
      return null;
    }
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
    _emissionsInterpreterOriginal?.close();
    _emissionsInterpreterNew?.close();
  }
}

List<List<List<List<double>>>> _preProcessImageWorker(String imagePath) {
  final imageData = File(imagePath).readAsBytesSync();
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
            pixel.r.toDouble(),
            pixel.g.toDouble(),
            pixel.b.toDouble(),
          ];
        },
      ),
    ),
  );
}
