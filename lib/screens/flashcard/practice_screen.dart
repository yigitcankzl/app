import 'package:flashcards_repo/flashcards_package.dart';
import 'package:flutter/material.dart';
import 'package:flashcards_repo/src/models/flashcard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PracticeScreen extends StatefulWidget {
  final FlashcardGroup flashcardGroup;

  PracticeScreen({required this.flashcardGroup});

  @override
  _PracticeScreenState createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  int currentIndex = 0;
  bool isFront = true;

  @override
  Widget build(BuildContext context) {
    if (widget.flashcardGroup.flashcards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Practice')),
        body: Center(child: Text('No flashcards available for practice')),
      );
    }

    Flashcard currentFlashcard = widget.flashcardGroup.flashcards[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Practice: ${widget.flashcardGroup.name}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('HOME'),
                ),
                Text(
                  '${currentIndex + 1} / ${widget.flashcardGroup.flashcards.length}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (currentIndex < widget.flashcardGroup.flashcards.length - 1) {
                        currentIndex++;
                        isFront = true;
                      }
                    });
                  },
                  child: Text(currentIndex < widget.flashcardGroup.flashcards.length - 1
                      ? 'NEXT CARD'
                      : 'FINISH'),
                ),
              ],
            ),

            // Flashcard Display
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      isFront = !isFront;
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        isFront ? currentFlashcard.word : currentFlashcard.meaning,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Action Buttons
            Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Edit card functionality
                  },
                  child: Text('EDIT CARD'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Change status functionality
                    setState(() {
                      currentFlashcard.status = currentFlashcard.status == 'memorized'
                          ? 'not memorized'
                          : 'memorized';
                    });
                    _updateFlashcardStatus(currentFlashcard);
                  },
                  child: Text('CHANGE STATUS'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isFront = !isFront;
                    });
                  },
                  child: Text('FLIP CARD'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _updateFlashcardStatus(Flashcard flashcard) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection('flashcard_groups')
        .doc(widget.flashcardGroup.id)
        .collection('flashcards')
        .doc(flashcard.id)
        .update({'status': flashcard.status}).catchError((error) {
      print('Error updating flashcard status: $error');
    });
  }
}
