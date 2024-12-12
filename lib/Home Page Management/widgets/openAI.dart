import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  // Updated to use Gemini 1.5 Pro model
  static final Uri chatUri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.0-pro-001:generateContent');

  static final Map<String, String> headers = {
    'Content-Type': 'application/json',
    'x-goog-api-key': "AIzaSyDZau_OXuWr78iQMtNIAib_ognrPLPpE0A",
  };

  Future<String?> request(String prompt, {
    int maxOutputTokens = 500,
    double temperature = 0.7,
  }) async {
    try {
      final requestBody = {
        "contents": [
          {
            "role": "user",
            "parts": [
              {"text": prompt}
            ]
          }
        ],
        "generationConfig": {
          "maxOutputTokens": maxOutputTokens,
          "temperature": temperature,
          "topP": 0.8,
          "topK": 20
        },
      };

      http.Response response = await http.post(
        chatUri,
        headers: headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['candidates'][0]['content']['parts'][0]['text']
            ?.trim();
      } else {
        return "Error: ${response.statusCode}";
      }
    } catch (e) {
      return "Error: $e";
    }
  }
}