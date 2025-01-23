import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  final String apiKey = 'AIzaSyBSzbJ2zLOiRfbugeqUyAG2yAT85d7FlQ4'; 

  Future<String> sendMessage(String prompt) async {
    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );

    final responses = model.generateContentStream([Content.text(prompt)]);
    StringBuffer completeResponse = StringBuffer();

    try {
      await for (final response in responses) {
        if (response.text != null) {
          completeResponse.write(response.text);
        }
      }
      return completeResponse.isEmpty ? 'No response text available' : completeResponse.toString();
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

}
