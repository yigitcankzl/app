import 'package:app/screens/lingva/lingva_screen.dart';
import 'package:flutter/material.dart';
import 'package:gemini_repo/gemini_package.dart';
import 'package:google_fonts/google_fonts.dart';

class GeminiScreen extends StatefulWidget {
  const GeminiScreen({super.key});

  @override
  _GeminiScreenState createState() => _GeminiScreenState();
}

class _GeminiScreenState extends State<GeminiScreen> {
  final TextEditingController _controller = TextEditingController();
  final GeminiService _geminiService = GeminiService();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  List<Map<String, String>> _messages = [];

  void _sendMessage() async {
    String userInput = _controller.text.trim();
    if (userInput.isEmpty) return;

    setState(() {
      _messages.add({'sender': 'User', 'text': userInput});
      _listKey.currentState?.insertItem(_messages.length - 1);
    });
    _controller.clear();
    FocusScope.of(context).unfocus();

    try {
      String result = await _geminiService.sendMessage(userInput);
      setState(() {
        _messages.add({'sender': 'Gemini', 'text': result});
        _listKey.currentState?.insertItem(_messages.length - 1);
      });
    } catch (e) {
      setState(() {
        _messages.add({'sender': 'Gemini', 'text': "Hata oluştu: $e"});
        _listKey.currentState?.insertItem(_messages.length - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      title: Text(
        'Gemini Chat',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          fontSize: 18, 
          color: Colors.white,
        ),
),        actions: [
          IconButton(
            onPressed: () {
              showTranslateSheet(context);
            },
            icon: const Icon(Icons.translate),
          ),
        ],
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.2),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF2F2F2), Color(0xFFE0E0E0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: AnimatedList(
                key: _listKey,
                padding: const EdgeInsets.all(10),
                initialItemCount: _messages.length,
                itemBuilder: (context, index, animation) {
                  bool isUser = _messages[index]['sender'] == 'User';
                  return SizeTransition(
                    sizeFactor: animation,
                    child: Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isUser ? Colors.deepPurple : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              spreadRadius: 1,
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Text(
                          _messages[index]['text']!,
                          style: GoogleFonts.poppins(
                            color: isUser ? Colors.white : Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: GoogleFonts.poppins(),
                      decoration: InputDecoration(
                        hintText: 'Talk with AI...',
                        hintStyle: GoogleFonts.poppins(color: Colors.grey.shade500),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FloatingActionButton(
                    backgroundColor: Colors.deepPurple,
                    elevation: 5,
                    onPressed: _sendMessage,
                    child: const Icon(Icons.send, color: Colors.white),
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
