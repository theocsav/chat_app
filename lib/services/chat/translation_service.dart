import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslationService {
  static const String _baseUrl = "https://api.mymemory.translated.net/get";

  /// Translates a given [text] from [currentLanguage] to [targetLanguage].
  /// Returns the translated string.
  Future<String> translateText({
    required String text,
    required String targetLanguage,
    required String currentLanguage,
  }) async {
    print("Debug: Translating '$text' from $currentLanguage to $targetLanguage");
    final Uri url = Uri.parse(_baseUrl).replace(queryParameters: {
      "q": text,
      "langpair": "$currentLanguage|$targetLanguage",
    });
    final response = await http.get(url);
    print("Debug: Translation request URL: $url");

    if (response.statusCode == 200) {
      print("Debug: Translation response: ${response.body}");
      final data = jsonDecode(response.body);
      return data['responseData']['translatedText'] ?? text;
    } else {
      print("Debug: Failed to translate, statusCode: ${response.statusCode}");
    }

    return text; // Return the original text if something fails
  }
}