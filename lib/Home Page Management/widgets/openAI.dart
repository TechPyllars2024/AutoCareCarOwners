import 'package:http/http.dart' as http;
import '../models/request_model.dart';
import '../models/response_model.dart';
import 'api_key.dart';

class ChatService {
  static final Uri chatUri = Uri.parse(
      'https://api.openai.com/v1/chat/completions');

  static final Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${ApiKey.openAIApiKey}',
  };

  Future<String?> request(String prompt) async {
    try {
      ChatRequest request = ChatRequest(
        model: "gpt-4o-mini",
        maxTokens: 500,
        messages: [Message(role: "user", content: prompt)],
      );
      http.Response response = await http.post(
        chatUri,
        headers: headers,
        body: request.toJson(),
      );
      if (response.statusCode == 200) {
        ChatResponse chatResponse = ChatResponse.fromResponse(response);
        return chatResponse.choices?[0].message?.content?.trim();
      } else {
        return "Error: ${response.statusCode}";
      }
    } catch (e) {
      return "Error: $e";
    }
  }
}