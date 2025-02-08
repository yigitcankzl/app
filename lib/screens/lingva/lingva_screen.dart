import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  String _sourceLang = 'en';
  String _targetLang = 'tr';

  void _translate() async {
    setState(() {
      _isLoading = true;
      _translatedText = '';
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

  void _swapLanguages() {
    setState(() {
      final temp = _sourceLang;
      _sourceLang = _targetLang;
      _targetLang = temp;
    });
  }

  void _clearText() {
    setState(() {
      _sourceController.clear();
      _translatedText = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Translate',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurpleAccent,
                ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: 5,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _sourceLang,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.language, color: Colors.deepPurpleAccent),
                    ),
                    items: ['en', 'es', 'fr', 'de', 'it', 'tr'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value.toUpperCase(), style: TextStyle(fontSize: 14)),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _sourceLang = newValue!;
                      });
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.swap_horiz, color: Colors.deepPurpleAccent),
                  onPressed: _swapLanguages,
                  tooltip: 'Swap languages',
                ),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _targetLang,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.translate, color: Colors.green),
                    ),
                    items: ['en', 'es', 'fr', 'de', 'it', 'tr'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value.toUpperCase(), style: TextStyle(fontSize: 14)),
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
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _sourceController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Enter text',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              prefixIcon: Icon(Icons.edit, color: Colors.deepPurpleAccent),
              suffixIcon: IconButton(
                icon: Icon(Icons.clear, color: Colors.deepPurpleAccent),
                onPressed: _clearText,
                tooltip: 'Clear text',
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isLoading ? null : _translate,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: Colors.deepPurpleAccent,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text('Translate', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 20),
          if (_translatedText.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _translatedText,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.copy, color: Colors.deepPurpleAccent),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _translatedText));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Text copied to clipboard')),
                      );
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

void showTranslateSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    isScrollControlled: true,
    builder: (context) {
      return const TranslatePanel();
    },
  );
}
