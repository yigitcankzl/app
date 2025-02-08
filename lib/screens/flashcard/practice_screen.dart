import 'package:app/screens/flashcard/flashcard_review_screen.dart';
import 'package:app/screens/lingva/lingva_screen.dart';
import 'package:flashcards_repo/flashcards_package.dart';
import 'package:flutter/material.dart';
import 'package:flashcards_repo/src/models/flashcard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class PracticeScreen extends StatefulWidget {
  final FlashcardGroup flashcardGroup;

  PracticeScreen({required this.flashcardGroup});

  @override
  _PracticeScreenState createState() => _PracticeScreenState();
}
class _PracticeScreenState extends State<PracticeScreen> {
  int currentIndex = 0;
  bool isFront = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _shuffleFlashcards();
  }

  void _shuffleFlashcards() {
    setState(() {
      List<Flashcard> weightedFlashcards = [];

      for (var flashcard in widget.flashcardGroup.flashcards) {
        if (flashcard.isFavorite) {
          weightedFlashcards.addAll(List.generate(2, (_) => flashcard));
        } else {
          weightedFlashcards.add(flashcard);
        }
      }

      weightedFlashcards.shuffle(Random());
      widget.flashcardGroup.flashcards = weightedFlashcards;
    });
  }

  void _updateFlashcardInGroup(Flashcard updatedFlashcard) async {
    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('flashcard_groups')
          .doc(widget.flashcardGroup.id)
          .collection('flashcards')
          .doc(updatedFlashcard.id)
          .update({
            'word': updatedFlashcard.word,
            'meaning': updatedFlashcard.meaning,
            'status': updatedFlashcard.status,
          });

      setState(() {
        int index = widget.flashcardGroup.flashcards
            .indexWhere((flashcard) => flashcard.id == updatedFlashcard.id);
        if (index != -1) {
          widget.flashcardGroup.flashcards[index] = updatedFlashcard;
        }
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print('Error updating flashcard in Firestore: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.flashcardGroup.flashcards.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Practice'),
          backgroundColor: Colors.deepPurple,
        ),
        body: Center(
          child: Text(
            'No flashcards available for practice',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ),
      );
    }

    Flashcard currentFlashcard = widget.flashcardGroup.flashcards[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Practice: ${widget.flashcardGroup.name}'),
        actions: [
          IconButton(
            onPressed: () {
              showTranslateSheet(context);
            },
            icon: const Icon(Icons.translate),
          ),
        ],
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReviewScreen(
                  flashcardGroup: widget.flashcardGroup,
                ),
              ),
            );
          },
        ),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      if (currentIndex > 0) {
                        currentIndex--;
                        isFront = true;
                      }
                    });
                  },
                  child: Text('PREVIOUS CARD'),
                ),
                Text(
                  '${currentIndex + 1} / ${widget.flashcardGroup.flashcards.length}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      if (currentIndex < widget.flashcardGroup.flashcards.length - 1) {
                        currentIndex++;
                        isFront = true;
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReviewScreen(
                              flashcardGroup: widget.flashcardGroup,
                            ),
                          ),
                        );
                      }
                    });
                  },
                  child: Text(currentIndex < widget.flashcardGroup.flashcards.length - 1
                      ? 'NEXT CARD'
                      : 'FINISH'),
                ),
              ],
            ),

            Expanded(
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      isFront = !isFront;
                    });
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    width: double.infinity,
                    height: 250,
                    decoration: BoxDecoration(
                      gradient: isFront
                          ? LinearGradient(
                              colors: [Colors.deepPurple, Colors.purpleAccent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : LinearGradient(
                              colors: [Colors.teal, Colors.cyan],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          spreadRadius: 4,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          isFront ? currentFlashcard.word : currentFlashcard.meaning,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Column(
              children: [
                SizedBox(height: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: currentFlashcard.status == 'memorized'
                        ? Colors.green
                        : Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      currentFlashcard.status = currentFlashcard.status == 'memorized'
                          ? 'not memorized'
                          : 'memorized';
                    });
                    _updateFlashcardStatus(currentFlashcard);
                  },
                  child: Text(
                    currentFlashcard.status == 'memorized'
                        ? 'MEMORIZED'
                        : 'NOT MEMORIZED',
                  ),
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

  void _showEditFlashcardDialog(Flashcard flashcard) {
    TextEditingController wordController = TextEditingController(text: flashcard.word);
    TextEditingController meaningController = TextEditingController(text: flashcard.meaning);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Flashcard'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: wordController,
                decoration: InputDecoration(labelText: 'Word'),
              ),
              TextField(
                controller: meaningController,
                decoration: InputDecoration(labelText: 'Meaning'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Flashcard updatedFlashcard = Flashcard(
                  id: flashcard.id,
                  word: wordController.text,
                  meaning: meaningController.text,
                  status: flashcard.status,
                );
                _updateFlashcardInGroup(updatedFlashcard);
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
