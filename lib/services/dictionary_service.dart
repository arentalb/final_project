import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

/// A service for translating words and images between English and Kurdish (Sorani)
class DictionaryService {
  //────────────────────────────────────────────────────────────────────────────
  // API configuration
  //────────────────────────────────────────────────────────────────────────────
  static const String _apiKey = 'AIzaSyCHdUEFQDV_Sh8Z1ZEFQ8hnv3CM6VBe5Lg';
  static final String _visionUrl =
      'https://vision.googleapis.com/v1/images:annotate?key=$_apiKey';
  static final String _geminiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/'
      'gemini-2.0-flash:generateContent?key=$_apiKey';

  /// Tracks the latest translate call to prevent race-condition fallout.
  int _lastRequestId = 0;

  DictionaryService();

  //────────────────────────────────────────────────────────────────────────────
  // Public API (with race-condition guard)
  //────────────────────────────────────────────────────────────────────────────

  /// Translate a single English word to Kurdish (Sorani).
  Future<String> fetchKurdishMeaning(String word) async {
    final callId = ++_lastRequestId;
    try {
      final result = await _translateWord(word, from: 'English', to: 'Kurdish (Sorani)');
      if (callId != _lastRequestId) {
        print('Discarding outdated Kurdish translation for "$word"');
        throw StateError('Outdated response');
      }
      return result;
    } catch (e, st) {
      print('Error in fetchKurdishMeaning: $e\n$st');
      rethrow;
    }
  }

  /// Translate a single Kurdish (Sorani) word to English.
  Future<String> fetchEnglishMeaning(String word) async {
    final callId = ++_lastRequestId;
    try {
      final result = await _translateWord(word, from: 'Kurdish (Sorani)', to: 'English');
      if (callId != _lastRequestId) {
        print('Discarding outdated English translation for "$word"');
        throw StateError('Outdated response');
      }
      return result;
    } catch (e, st) {
      print('Error in fetchEnglishMeaning: $e\n$st');
      rethrow;
    }
  }

  /// Perform OCR on an image and translate its full text to Kurdish (Sorani).
  Future<String> translateImageToKurdish(Uint8List imageBytes) async {
    try {
      return await _extractAndTranslateText(
        imageBytes,
        from: 'English',
        to: 'Kurdish (Sorani)',
      );
    } catch (e, st) {
      print('Error in translateImageToKurdish: $e\n$st');
      rethrow;
    }
  }

  /// Perform OCR on an image and translate its full text to English.
  Future<String> translateImageToEnglish(Uint8List imageBytes) async {
    try {
      return await _extractAndTranslateText(
        imageBytes,
        from: 'Kurdish (Sorani)',
        to: 'English',
      );
    } catch (e, st) {
      print('Error in translateImageToEnglish: $e\n$st');
      rethrow;
    }
  }

  //────────────────────────────────────────────────────────────────────────────
  // Private HTTP with retry logic for 429
  //────────────────────────────────────────────────────────────────────────────

  Future<http.Response> _postWithRetry(
      Uri uri,
      String body, {
        Map<String, String>? headers,
        int retries = 3,
      }) async {
    http.Response response;
    for (int attempt = 1; attempt <= retries; attempt++) {
      response = await http.post(uri, headers: headers, body: body);
      if (response.statusCode != 429) {
        return response;
      }
      // Quota exceeded: parse retry info or default to 5s
      int delayMs = 5000;
      try {
        final err = jsonDecode(response.body);
        final retryInfo = (err['error']['details'] as List?)
            ?.firstWhere(
              (d) => d['@type']?.endsWith('RetryInfo') == true,
          orElse: () => null,
        );
        if (retryInfo != null && retryInfo['retryDelay'] is String) {
          final s = retryInfo['retryDelay'] as String;
          final match = RegExp(r"(\\d+)([sm])").firstMatch(s);
          if (match != null) {
            final value = int.parse(match.group(1)!);
            delayMs = value * (match.group(2) == 'm' ? 60000 : 1000);
          }
        }
      } catch (_) {}
      print('Rate limited, retrying in \${delayMs}ms (attempt \$attempt)');
      await Future.delayed(Duration(milliseconds: delayMs));
    }
    // Final attempt
    return http.post(uri, headers: headers, body: body);
  }

  //────────────────────────────────────────────────────────────────────────────
  // Private helpers
  //────────────────────────────────────────────────────────────────────────────

  /// Translates a single word using the Gemini API.
  Future<String> _translateWord(
      String word, {
        required String from,
        required String to,
      }) async {
    final uri = Uri.parse(_geminiUrl);
    final prompt = '''
Translate the SINGLE word "$word" from $from to $to.
Respond with EXACTLY the translated word and NOTHING else.
''';

    final payload = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt.trim()}
          ],
        }
      ],
      'generationConfig': {
        'temperature': 0.0,
        'maxOutputTokens': 3,
      },
    });

    final response = await _postWithRetry(
      uri,
      payload,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      print('Translation API error: \${response.statusCode} - \${response.body}');
      throw HttpException(
        'Translation API error: \${response.statusCode}',
        uri: uri,
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final text = (data['candidates'] as List)
        .first['content']['parts']
        .first['text'] as String?;

    if (text == null || text.trim().isEmpty) {
      print('Empty translation for "$word"');
      throw FormatException('Empty translation for "$word"');
    }

    return text.trim();
  }

  /// Extracts text from an image via OCR and then translates it.
  Future<String> _extractAndTranslateText(
      Uint8List imageBytes, {
        required String from,
        required String to,
      }) async {
    final visionUri = Uri.parse(_visionUrl);
    final visionPayload = jsonEncode({
      'requests': [
        {
          'image': {'content': base64Encode(imageBytes)},
          'features': [
            {'type': 'TEXT_DETECTION'}
          ],
        }
      ]
    });

    final visionResp = await _postWithRetry(
      visionUri,
      visionPayload,
      headers: {'Content-Type': 'application/json'},
    );
    if (visionResp.statusCode != 200) {
      print('OCR API error: \${visionResp.statusCode} - \${visionResp.body}');
      throw HttpException(
        'OCR API error: \${visionResp.statusCode}',
        uri: visionUri,
      );
    }

    final ocrData = jsonDecode(visionResp.body) as Map<String, dynamic>;
    final extracted = (ocrData['responses'] as List)
        .first['textAnnotations']
        .first['description'] as String?;
    if (extracted == null || extracted.isEmpty) {
      print('No text found in image');
      throw FormatException('No text found in image');
    }

    final translateUri = Uri.parse(_geminiUrl);
    final prompt = '''
Translate the following text from $from to $to:
"""
$extracted
"""
''';
    final translatePayload = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt.trim()}
          ],
        }
      ]
    });

    final translateResp = await _postWithRetry(
      translateUri,
      translatePayload,
      headers: {'Content-Type': 'application/json'},
    );
    if (translateResp.statusCode != 200) {
      print('Translation API error: \${translateResp.statusCode} - \${translateResp.body}');
      throw HttpException(
        'Translation API error: \${translateResp.statusCode}',
        uri: translateUri,
      );
    }

    final tdata = jsonDecode(translateResp.body) as Map<String, dynamic>;
    final translated = (tdata['candidates'] as List)
        .first['content']['parts']
        .first['text'] as String?;
    if (translated == null || translated.trim().isEmpty) {
      print('Empty translated text block');
      throw FormatException('Empty translated text');
    }

    return translated.trim();
  }
}
