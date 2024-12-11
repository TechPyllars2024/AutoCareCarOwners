import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiKey {
  static String? openAIApiKey = dotenv.env['OPENAIKEY'];
  static String? googleApiKey = dotenv.env['GOOGLEAPIKEY'];
}
