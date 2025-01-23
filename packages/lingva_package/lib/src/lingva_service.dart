import 'dart:convert';
import 'package:http/http.dart' as http;

class LingvaService {
  final String baseUrl = "https://lingva.ml";

  Future<String> translateText(String sourceLang, String targetLang, String query) async {
    final Uri url = Uri.parse('$baseUrl/api/v1/$sourceLang/$targetLang/$query');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data.containsKey('translation')) {
        return data['translation'];
      } else {
        throw Exception('Translating errror: ${data['error']}');
      }
    } else {
      throw Exception('HTTP error: ${response.statusCode}');
    }
  }

  Future<List<Map<String, String>>> getLanguages(String type) async {
    final Uri url = Uri.parse('$baseUrl/api/v1/languages/?$type');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return List<Map<String, String>>.from(data['languages']);
    } else {
      throw Exception('getting language error: ${response.statusCode}');
    }
  }

  Future<List<int>> getAudioPronunciation(String lang, String query) async {
    final Uri url = Uri.parse('$baseUrl/api/v1/audio/$lang/$query');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return List<int>.from(data['audio']);
    } else {
      throw Exception('audio error: ${response.statusCode}');
    }
  }
}