  import 'package:flutter/material.dart';
import 'package:lingva_repo/lingva_package.dart';

class TranslatePanel extends StatefulWidget {
  const TranslatePanel({super.key});

  @override
  _TranslatePanelState createState() => _TranslatePanelState();
}

class _TranslatePanelState extends State<TranslatePanel> {
  final LingvaService _lingvaService = LingvaService();
  String _translatedText = '';
  bool _isLoading = false;
  final TextEditingController _sourceController = TextEditingController();
  String _sourceLang = 'en'; // Default source language
  String _targetLang = 'tr'; // Default target language

  void _translate() async {
    setState(() {
      _isLoading = true;
      _translatedText = ''; // Clear previous result
    });

    try {
      final translated = await _lingvaService.translateText(
        _sourceLang, _targetLang, _sourceController.text);
      setState(() {
        _translatedText = translated;
      });
    } catch (e) {
      setState(() {
        _translatedText = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Translate Section',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 8),
          TextField(
            controller: _sourceController,
            decoration: InputDecoration(
              labelText: 'Enter text to translate',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButton<String>(
                  value: _sourceLang,
                  items: <String>['en', 'es', 'fr', 'de', 'it', 'tr'] // Example languages
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _sourceLang = newValue!;
                    });
                  },
                ),
              ),
              Icon(Icons.arrow_forward),
              Expanded(
                child: DropdownButton<String>(
                  value: _targetLang,
                  items: <String>['en', 'es', 'fr', 'de', 'it','tr'] // Example languages
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _targetLang = newValue!;
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isLoading ? null : _translate,
            child: _isLoading 
                ? CircularProgressIndicator(color: Colors.white)
                : const Text('Translate Now'),
          ),
          SizedBox(height: 16),
          if (_translatedText.isNotEmpty) 
            Text(
              'Translation: $_translatedText',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
        ],
      ),
    );
  }
}

void showTranslateSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    isScrollControlled: true,
    builder: (context) {
      return const TranslatePanel(); // Paneli buradan çağırıyoruz
    },
  );
}