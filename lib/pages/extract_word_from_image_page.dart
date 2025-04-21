import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Model for a word extracted from an image (Kurdish).
class ExtractedWord {
  final String original;
  String? translation;
  ExtractedWord(this.original, {this.translation});
}

/// Service for OCR (Vision API) and translation (Gemini).
class DictionaryService {
  static const String _apiKey = 'YOUR_GOOGLE_API_KEY';
  static final String _visionUrl =
      'https://vision.googleapis.com/v1/images:annotate?key=$_apiKey';
  static final String _geminiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/'
      'gemini-2.0-flash:generateContent?key=$_apiKey';

  DictionaryService();

  /// Extracts raw text from an image via Google Vision OCR.
  Future<String> extractRawText(Uint8List imageBytes) async {
    final uri = Uri.parse(_visionUrl);
    final payload = jsonEncode({
      'requests': [
        {
          'image': {'content': base64Encode(imageBytes)},
          'features': [{'type': 'TEXT_DETECTION'}],
        }
      ]
    });
    final resp = await _postWithRetry(uri, payload,
        headers: {'Content-Type': 'application/json'});
    if (resp.statusCode != 200) {
      print('OCR API error: ${resp.statusCode} - ${resp.body}');
      throw HttpException('OCR API error: ${resp.statusCode}', uri: uri);
    }
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final annotations = (data['responses'] as List).first['textAnnotations'] as List<dynamic>?;
    final text = annotations?.first['description'] as String?;
    if (text == null || text.isEmpty) {
      print('No text found in image');
      throw FormatException('No text found');
    }
    return text;
  }

  /// Translates the raw OCR text block via Gemini and returns English text.
  Future<String> translateTextBlock(String rawText) async {
    final uri = Uri.parse(_geminiUrl);
    final prompt = '''
Translate the following text from Kurdish (Sorani) to English:\n"""
$rawText
"""''';
    final payload = jsonEncode({
      'contents': [
        {'parts': [{'text': prompt.trim()}]}
      ]
    });

    final resp = await _postWithRetry(uri, payload,
        headers: {'Content-Type': 'application/json'});
    if (resp.statusCode != 200) {
      print('Translation API error: ${resp.statusCode} - ${resp.body}');
      throw HttpException('Translation API error: ${resp.statusCode}', uri: uri);
    }
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final text = (data['candidates'] as List)
        .first['content']['parts']
        .first['text'] as String?;
    if (text == null || text.trim().isEmpty) {
      print('Empty translation block');
      throw FormatException('Empty translation');
    }
    return text.trim();
  }

  /// Combined OCR + translation for convenience.
  Future<String> translateImage(Uint8List imageBytes) async {
    final raw = await extractRawText(imageBytes);
    return await translateTextBlock(raw);
  }

  /// Retry helper for handling 429 rate limits.
  Future<http.Response> _postWithRetry(
      Uri uri,
      String body, {
        Map<String, String>? headers,
        int retries = 3,
      }) async {
    http.Response response;
    for (var attempt = 1; attempt <= retries; attempt++) {
      response = await http.post(uri, headers: headers, body: body);
      if (response.statusCode != 429) return response;
      // parse retry delay
      int delayMs = 5000;
      try {
        final err = jsonDecode(response.body);
        final ri = (err['error']['details'] as List?)
            ?.firstWhere((d) => d['@type']?.endsWith('RetryInfo') == true,
            orElse: () => null);
        if (ri != null && ri['retryDelay'] is String) {
          final m = RegExp(r"(\d+)([sm])").firstMatch(ri['retryDelay']);
          if (m != null) {
            final v = int.parse(m.group(1)!);
            delayMs = v * (m.group(2) == 'm' ? 60000 : 1000);
          }
        }
      } catch (_) {}
      print('Rate limited, retrying in ${delayMs}ms (attempt $attempt)');
      await Future.delayed(Duration(milliseconds: delayMs));
    }
    return http.post(uri, headers: headers, body: body);
  }
}

/// Flutter widget: pick image, OCR, translate, display.
class CreateFromImagePage extends StatefulWidget {
  const CreateFromImagePage({Key? key}) : super(key: key);
  @override
  State<CreateFromImagePage> createState() => _CreateFromImagePageState();
}

class _CreateFromImagePageState extends State<CreateFromImagePage> {
  final _service = DictionaryService();
  final _picker = ImagePicker();
  bool _loading = false;
  Uint8List? _image;
  String? _result;

  Future<void> _pickAndProcess() async {
    setState(() { _loading = true; _image = null; _result = null; });
    try {
      Uint8List? bytes;
      if (kIsWeb) {
        final res = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
        if (res?.files.first.bytes == null) throw 'No file';
        bytes = res!.files.first.bytes;
      } else {
        final fx = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
        if (fx == null) throw 'No image';
        bytes = await fx.readAsBytes();
      }
      setState(() => _image = bytes);
      final translated = await _service.translateImage(bytes!);
      setState(() => _result = translated);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('وەرگێڕی وێنە')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              FButton(label: const Text('Select & Translate Image'), onPress: _pickAndProcess, style: FButtonStyle.primary),
              const SizedBox(height: 16),
              if (_loading) const CircularProgressIndicator(),
              if (_image != null) ...[
                const SizedBox(height: 16),
                Image.memory(_image!, height: 200),
              ],
              if (_result != null) ...[
                const SizedBox(height: 16),
                Expanded(child: SingleChildScrollView(child: Text(_result!))),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
