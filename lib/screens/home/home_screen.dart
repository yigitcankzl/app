import 'package:app/screens/lingva/lingva_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:app/screens/flashcard/flashcards_screen.dart';
import 'package:app/screens/gemini/gemini_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('updating'),
        actions: [
          IconButton(
            onPressed: () {
              // Sign out the user
              context.read<SignInBloc>().add(const SignOutRequired());
            },
            icon: const Icon(Icons.login),
          ),
          IconButton(
            onPressed: () {
              showTranslateSheet(context); // Paneli açan fonksiyonu çağırıyoruz
            },
            icon: const Icon(Icons.translate),
          ),
        ],
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FlashcardsScreen()),
              );
            },
            child: const Text('Flashcard'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GeminiScreen()),
              );
            },
            child: const Text('Gemini'),
          ),
        ],
      ),
    );
  }
}
