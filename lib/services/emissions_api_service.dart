import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EmissionsApiService {
  // We specify the model directly in the endpoint URL for Google's official API
  static const String _model = 'gemini-2.5-flash';

  Future<Map<String, dynamic>?> getVehicleSpecs(String model, String year) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      print('GEMINI_API_KEY not found in .env');
      return null;
    }

    try {
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$apiKey',
      );

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'systemInstruction': {
            'parts': [
              {
                'text': 'You are a vehicle specification database. Respond ONLY with a valid JSON object, without any markdown formatting or surrounding text. Extract the engine size in liters (float), number of cylinders (int), and fuel type mapped to an integer (0 for Regular/Premium Petrol/Gasoline, 1 for Premium, 2 for Diesel, 3 for Ethanol/E85, 4 for Natural Gas/Electric). Default to 0 for unknown Petrol. Use the format: {"engine_size": 2.0, "cylinders": 4, "fuel_type": 0}.'
              }
            ]
          },
          'contents': [
            {
              'parts': [
                {
                  'text': 'Vehicle: $year $model'
                }
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final contentStr = data['candidates'][0]['content']['parts'][0]['text'] as String;
        
        // Clean markdown backticks if any
        final cleanContent = contentStr.replaceAll('```json', '').replaceAll('```', '').trim();
        final jsonResult = jsonDecode(cleanContent);
        
        return {
          'engine_size': (jsonResult['engine_size'] ?? 2.0).toDouble(),
          'cylinders': (jsonResult['cylinders'] ?? 4).toInt(),
          'fuel_type': (jsonResult['fuel_type'] ?? 0).toInt(),
        };
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error calling API: $e');
      return null;
    }
  }
}
