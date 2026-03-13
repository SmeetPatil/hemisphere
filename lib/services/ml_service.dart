import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class MLService {
  Interpreter? _safetyInterpreter;
  Interpreter? _garbageInterpreter;

  // Accident: accident, construction, normal
  final List<String> _safetyClasses = ['accident', 'construction', 'normal'];
  // Garbage: garbage, clean
  final List<String> _garbageClasses = ['clean', 'garbage'];

  Future<void> init() async {
    try {
      _safetyInterpreter = await Interpreter.fromAsset('assets/models/safety_model.tflite');
      _garbageInterpreter = await Interpreter.fromAsset('assets/models/garbage_classification_model.tflite');
      print('Models loaded successfully');
    } catch (e) {
      print('Failed to load models: $e');
    }
  }

  Future<String?> predictSafety(File imageFile) async {
    if (_safetyInterpreter == null) {
      print("Safety interpreter is null");
      return "Model not loaded";
    }

    try {
      var input = _preProcessImage(imageFile);
      // Adjust the output shape according to your specific tflite model output shape
      var output = List.filled(1 * 3, 0.0).reshape([1, 3]);

      _safetyInterpreter!.run(input, output);
      return _getLabel(output[0], _safetyClasses);
    } catch (e) {
      print("Prediction error (safety): $e");
      return "Prediction failed";
    }
  }

  Future<String?> predictGarbage(File imageFile) async {
    if (_garbageInterpreter == null) {
      print("Garbage interpreter is null");
      return "Model not loaded";
    }

    try {
      var input = _preProcessImage(imageFile);
      // Adjust the output shape according to your specific tflite model output shape
      var output = List.filled(1 * 2, 0.0).reshape([1, 2]);

      _garbageInterpreter!.run(input, output);
      return _getLabel(output[0], _garbageClasses);
    } catch (e) {
      print("Prediction error (garbage): $e");
      return "Prediction failed";
    }
  }

  List<List<List<List<double>>>> _preProcessImage(File imageFile) {
    // Read image
    final imageData = imageFile.readAsBytesSync();
    img.Image? originalImage = img.decodeImage(imageData);

    // Resize image to what the model expects, commonly 224x224
    final image = img.copyResize(originalImage!, width: 224, height: 224);

    // Convert to normalized format
    final input = List.generate(
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

    return input;
  }

  String _getLabel(List<double> probabilities, List<String> labels) {
    double maxProb = double.negativeInfinity;
    int maxIndex = -1;

    for (int i = 0; i < probabilities.length; i++) {
      if (probabilities[i] > maxProb) {
        maxProb = probabilities[i];
        maxIndex = i;
      }
    }

    return labels[maxIndex];
  }

  void dispose() {
    _safetyInterpreter?.close();
    _garbageInterpreter?.close();
  }
}
