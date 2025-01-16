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
    final Uri url = Uri.parse(_baseUrl).replace(queryParameters: {
      "q": text,
      "langpair": "$currentLanguage|$targetLanguage",
    });

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['responseData']['translatedText'] ?? text;
    }

    return text; // Return the original text if something fails
  }
}
