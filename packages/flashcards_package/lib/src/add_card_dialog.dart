import 'package:flashcards_repo/src/models/flashcard.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flashcards_repo/flashcards_package.dart';

class AddCardDialog extends StatefulWidget {
  final FlashcardGroup flashcardGroup;
  final VoidCallback onFlashcardAdded;

  AddCardDialog({required this.flashcardGroup, required this.onFlashcardAdded});

  @override
  _AddCardDialogState createState() => _AddCardDialogState();
}

class _AddCardDialogState extends State<AddCardDialog> {
  final _formKey = GlobalKey<FormState>();
  final _wordController = TextEditingController();
  final _meaningController = TextEditingController();
  String? userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void dispose() {
    _wordController.dispose();
    _meaningController.dispose();
    super.dispose();
  }

  void _addFlashcard() async {
    if (_formKey.currentState?.validate() ?? false) {
      String word = _wordController.text.trim();
      String meaning = _meaningController.text.trim();

      if (userId != null) {
        try {
          DocumentReference flashcardRef = FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('flashcard_groups')
              .doc(widget.flashcardGroup.id)
              .collection('flashcards')
              .doc();

          Flashcard newFlashcard = Flashcard(
            id: flashcardRef.id,
            word: word,
            meaning: meaning,
            status: 'not memorized',
            isFavorite: false,
          );

          await flashcardRef.set({
            'id': flashcardRef.id,
            'word': word,
            'meaning': meaning,
            'status': 'not memorized',
            'isFavorite': false,
            'groupId': widget.flashcardGroup.id,
            'userId': userId,
          });

          setState(() {
            widget.flashcardGroup.flashcards.add(newFlashcard);
          });

          widget.onFlashcardAdded();

          Navigator.pop(context);
        } catch (error) {
          print('Error adding flashcard: $error');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error adding flashcard. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        print('User is not logged in');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please log in to add flashcards.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add New Flashcard'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _wordController,
              decoration: InputDecoration(labelText: 'Word'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a word';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _meaningController,
              decoration: InputDecoration(labelText: 'Meaning'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a meaning';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addFlashcard,
          child: Text('Add'),
        ),
      ],
    );
  }
}
