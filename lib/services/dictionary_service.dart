import 'dart:convert';
import 'package:http/http.dart' as http;

class DictionaryService {
  final String _baseUrl = 'https://api.mymemory.translated.net/get';
  String? email;

  DictionaryService({this.email});

  /// Translate from English to Kurdish (Sorani)
  Future<String> fetchKurdishMeaning(String word) async {
    return _translateAndClean(word, 'en', 'ckb');
  }

  /// Translate from Kurdish (Sorani) to English
  Future<String> fetchEnglishMeaning(String word) async {
    return _translateAndClean(word, 'ckb', 'en');
  }

  /// Core translation method + cleaning step
  Future<String> _translateAndClean(String word, String fromLang, String toLang) async {
    final uri = Uri.parse(
      '$_baseUrl?q=${Uri.encodeComponent(word)}&langpair=$fromLang|$toLang&mt=0${email != null ? '&de=$email' : ''}',
    );

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rawTranslation = data['responseData']['translatedText'];

        return _cleanTranslation(rawTranslation);
      } else {
        return 'No Translation';
      }
    } catch (e) {
      return 'No Translation';
    }
  }

  /// Clean translation to get only the first word, removing punctuation
  String _cleanTranslation(String input) {
    return input
        .split(RegExp(r'[\s،،؛,;:.؟!?]')) // Split on spaces and punctuation
        .first
        .replaceAll(RegExp(r'[^\p{L}]', unicode: true), '') // Keep letters only
        .trim();
  }
}
