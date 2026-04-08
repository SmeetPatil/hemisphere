import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EmissionsApiService {
  // Used by UI Autocomplete to fetch suggestions using an LLM via Groq (Llama 3)
  Future<List<Map<String, dynamic>>> searchVehicles(String query) async {
    if (query.trim().isEmpty) return [];

    final apiKey = dotenv.env['GROQ_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      print('GROQ_API_KEY not found in .env');
      return [];
    }

    final url = Uri.parse('https://api.groq.com/openai/v1/chat/completions');

    final prompt = '''
Find cars or motorcycles matching the search query: "$query".
Provide a list of up to 15 matching vehicles with their specific manufacturing years.
Return ONLY a valid JSON array of objects with "name" (Make and Model) and "year" (String) properties. If the vehicle was made over multiple years, return multiple objects for the most relevant/common years.
Example: [{"name": "Suzuki Grand Vitara", "year": "2005"}, {"name": "Suzuki Grand Vitara", "year": "2006"}] 
''';

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey'
        },
        body: jsonEncode({
          'model': 'llama-3.1-8b-instant',
          'messages': [
            {'role': 'system', 'content': 'You are a vehicle database API. You must output ONLY a valid JSON array. Do not wrap in markdown blocks like ```json.'},
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.0
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        var contentText = data['choices']?[0]?['message']?['content']?.toString().trim();

        if (contentText != null) {
          if (contentText.startsWith('```json')) {
            contentText = contentText.replaceAll('```json', '').replaceAll('```', '').trim();
          } else if (contentText.startsWith('```')) {
            contentText = contentText.replaceAll('```', '').trim();
          }

          final List<dynamic> results = jsonDecode(contentText);
          return results.map((item) => <String, dynamic>{
            'name': item['name']?.toString() ?? '',
            'year': item['year']?.toString() ?? '',
          }).toList();
        }
      } else {
        print('Groq API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error calling Groq API: $e');
    }
    return [];
  }

  Future<Map<String, dynamic>?> getVehicleSpecs(String model, String year) async {
    final apiKey = dotenv.env['GROQ_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      print('GROQ_API_KEY not found in .env');
      return null;
    }

    final url = Uri.parse('https://api.groq.com/openai/v1/chat/completions');

    final prompt = '''
Provide the technical specifications for a "$year $model". If the exact vehicle model is not found or is ambiguous, do not make up unrealistic values—instead, provide the specifications for a typical average mid-size car (e.g. engine_size: 2.0, cylinders: 4, fuel_type: 0). Ensure engine_size rarely exceeds 8.0.
Return ONLY a valid JSON object with the following properties:
- "engine_size": Engine displacement in Liters as a double (e.g. 2.4). If electric, return 0.0.
- "cylinders": Number of engine cylinders as an integer (e.g. 4, 6). If electric or rotary, return 0.       
- "fuel_type": Integer representing the fuel type (0 = Regular Gasoline, 1 = Premium Gasoline, 2 = Diesel, 3 = Ethanol/E85, 4 = Electric/Natural Gas).
Example: {"engine_size": 2.4, "cylinders": 4, "fuel_type": 0}
''';

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey'
        },
        body: jsonEncode({
          'model': 'llama-3.1-8b-instant',
          'messages': [
            {'role': 'system', 'content': 'You are a vehicle database API. You must output ONLY a valid JSON object. Do not wrap in markdown blocks like ```json.'},
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.0
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        var contentText = data['choices']?[0]?['message']?['content']?.toString().trim();

        if (contentText != null) {
          if (contentText.startsWith('```json')) {
            contentText = contentText.replaceAll('```json', '').replaceAll('```', '').trim();
          } else if (contentText.startsWith('```')) {
            contentText = contentText.replaceAll('```', '').trim();
          }

          final Map<String, dynamic> result = jsonDecode(contentText);
          
          double eSize;
          var rawESize = result['engine_size'];
          if (rawESize is num) {
            eSize = rawESize.toDouble();
          } else if (rawESize is String) {
            eSize = double.tryParse(rawESize.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 2.0;
          } else {
            eSize = 2.0;
          }

          // If the LLM returned CCs instead of Liters (e.g., 2400 instead of 2.4)
          if (eSize > 50.0) {
            eSize = eSize / 1000.0;
          }
          // Hard cap to prevent insanely high emission numbers
          if (eSize > 8.0 || eSize < 0.0) eSize = 2.0;

          int cyls;
          var rawCyls = result['cylinders'];
          if (rawCyls is num) {
            cyls = rawCyls.toInt();
          } else if (rawCyls is String) {
            cyls = int.tryParse(rawCyls.replaceAll(RegExp(r'[^0-9]'), '')) ?? 4;
          } else {
            cyls = 4;
          }
          if (cyls > 16 || cyls < 0) cyls = 4;

          int fType;
          var rawFType = result['fuel_type'];
          if (rawFType is num) {
            fType = rawFType.toInt();
          } else if (rawFType is String) {
            fType = int.tryParse(rawFType.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
          } else {
            fType = 0;
          }
          if (fType < 0 || fType > 4) fType = 0;

          return {
            'engine_size': eSize,
            'cylinders': cyls,
            'fuel_type': fType,
          };
        }
      } else {
         print('Groq API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error calling Groq API: $e');
    }

    return null;
  }
}
