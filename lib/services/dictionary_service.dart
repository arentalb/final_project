import 'dart:convert';
import 'package:http/http.dart' as http;

class DictionaryService {
  final String _baseUrl = 'https://api.mymemory.translated.net/get';
  String? email;

  DictionaryService({this.email});

  Future<String> fetchKurdishMeaning(String word) async {
    return _translateAndClean(word, 'en', 'ckb');
  }

  Future<String> fetchEnglishMeaning(String word) async {
    return _translateAndClean(word, 'ckb', 'en');
  }

  Future<String> _translateAndClean(String word, String fromLang, String toLang) async {
    final uri = Uri.parse(
      '$_baseUrl?q=${Uri.encodeComponent(word)}&langpair=$fromLang|$toLang&mt=0${email != null ? '&de=$email' : ''}',
    );

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rawTranslation = data['responseData']['translatedText'];


        return rawTranslation
            .split(RegExp(r'[\s،،؛,;:.؟!?]'))
            .first
            .replaceAll(RegExp(r'[^\p{L}]', unicode: true), '')
            .trim();
      } else {
        return 'No Translation';
      }
    } catch (e) {
      return 'No Translation';
    }
  }

}
