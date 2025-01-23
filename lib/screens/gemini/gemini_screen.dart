import 'package:flutter/material.dart';
import 'package:gemini_repo/gemini_package.dart';

class GeminiScreen extends StatefulWidget {
  const GeminiScreen({super.key});

  @override
  _GeminiScreenState createState() => _GeminiScreenState();
}

class _GeminiScreenState extends State<GeminiScreen> {
  final TextEditingController _controller = TextEditingController();
  final GeminiService _geminiService = GeminiService();
  List<Map<String, String>> _messages = [];

  void _sendMessage() async {
    String userInput = _controller.text.trim();
    if (userInput.isEmpty) return;

    setState(() {
      _messages.add({'sender': 'User', 'text': userInput});
    });
    _controller.clear();
    FocusScope.of(context).unfocus(); // Klavyeyi kapat

    try {
      String result = await _geminiService.sendMessage(userInput);
      setState(() {
        _messages.add({'sender': 'Gemini', 'text': result});
      });
    } catch (e) {
      setState(() {
        _messages.add({'sender': 'Gemini', 'text': "Hata oluştu: $e"});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gemini Chat'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Container(
        color: Colors.grey[200], // Arkaplan rengi
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  bool isUser = _messages[index]['sender'] == 'User';
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: isUser ? Colors.deepPurple : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(20),
                          topRight: const Radius.circular(20),
                          bottomLeft: isUser ? const Radius.circular(20) : Radius.zero,
                          bottomRight: isUser ? Radius.zero : const Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Text(
                        _messages[index]['text']!,
                        style: TextStyle(
                          color: isUser ? Colors.white : Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Talk with AI...',
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    backgroundColor: Colors.deepPurple,
                    radius: 25,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
