import 'package:app/screens/flashcard/flashcards_screen.dart';
import 'package:app/screens/flashcard/practice_screen.dart';
import 'package:app/screens/lingva/lingva_screen.dart';
import 'package:flutter/material.dart';
import 'package:flashcards_repo/flashcards_package.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flashcards_repo/src/models/flashcard.dart';
import 'package:flashcards_repo/src/add_card_dialog.dart';


class ReviewScreen extends StatefulWidget {
  final FlashcardGroup flashcardGroup;

  ReviewScreen({required this.flashcardGroup});

  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  late FlashcardGroup flashcardGroup;

  @override
  void initState() {
    super.initState();
    // _loadFlashcards();
  }

  void _swapWordMeaning() {
    setState(() {
      for (var flashcard in widget.flashcardGroup.flashcards) {
        String temp = flashcard.word;
        flashcard.word = flashcard.meaning;
        flashcard.meaning = temp;
      }
    });

    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      for (var flashcard in widget.flashcardGroup.flashcards) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('flashcard_groups')
            .doc(widget.flashcardGroup.id)
            .collection('flashcards')
            .doc(flashcard.id)
            .update({
              'word': flashcard.word,
              'meaning': flashcard.meaning,
            })
            .catchError((error) {
          print('Error updating flashcard: $error');
        });
      }
    }
  }

  void _loadFlashcards() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('flashcard_groups')
          .doc(widget.flashcardGroup.id)
          .collection('flashcards')
          .get()
          .then((snapshot) {
        List<Flashcard> loadedFlashcards = [];
        for (var doc in snapshot.docs) {
          loadedFlashcards.add(
            Flashcard(
              id: doc.id,
              word: doc['word'],
              meaning: doc['meaning'],
              status: doc['status'],
              isFavorite: doc['isFavorite'],
            ),
          );
        }
        setState(() {
          widget.flashcardGroup.flashcards = loadedFlashcards;
        });
      }).catchError((error) {
        print('Error loading flashcards: $error');
      });
    } else {
      print('User is not logged in');
    }
  }

  void _deleteFlashcard(Flashcard flashcard, int index) {
    setState(() {
      widget.flashcardGroup.flashcards.removeAt(index);
    });

    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection('flashcard_groups')
        .doc(widget.flashcardGroup.id)
        .collection('flashcards')
        .doc(flashcard.id)
        .delete()
        .catchError((error) {
      print('Error deleting flashcard: $error');
    });
  }

  void _toggleFavorite(Flashcard flashcard, int index) {
    setState(() {
      flashcard.isFavorite = !flashcard.isFavorite;
    });

    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection('flashcard_groups')
        .doc(widget.flashcardGroup.id)
        .collection('flashcards')
        .doc(flashcard.id)
        .update({'isFavorite': flashcard.isFavorite})
        .catchError((error) {
      print('Error updating favorite status: $error');
    });
  }

  void _showEditDialog(Flashcard flashcard, int index) {
    final _wordController = TextEditingController(text: flashcard.word);
    final _meaningController = TextEditingController(text: flashcard.meaning);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.deepPurple[50],
          title: Text('Edit Flashcard', style: TextStyle(color: Colors.deepPurple[900], fontWeight: FontWeight.bold)),
          content: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _wordController,
                  decoration: InputDecoration(
                    labelText: 'Word',
                    labelStyle: TextStyle(color: Colors.deepPurple[800]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _meaningController,
                  decoration: InputDecoration(
                    labelText: 'Meaning',
                    labelStyle: TextStyle(color: Colors.deepPurple[800]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel', style: TextStyle(color: Colors.deepPurple[900])),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                setState(() {
                  flashcard.word = _wordController.text.trim();
                  flashcard.meaning = _meaningController.text.trim();
                });

                FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser?.uid)
                    .collection('flashcard_groups')
                    .doc(widget.flashcardGroup.id)
                    .collection('flashcards')
                    .doc(flashcard.id)
                    .update({
                      'word': flashcard.word,
                      'meaning': flashcard.meaning,
                    })
                    .then((_) {
                      Navigator.pop(context);
                    })
                    .catchError((error) {
                      print('Error updating flashcard: $error');
                    });
              },
              child: Text('Update', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _startPractice() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PracticeScreen(
          flashcardGroup: widget.flashcardGroup,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        title: Text(
          '${widget.flashcardGroup.name} Review',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              showTranslateSheet(context);
            },
            icon: const Icon(Icons.translate, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard('Total', widget.flashcardGroup.flashcards.length.toString(), Colors.deepPurple),
                _buildStatCard('Memorized', widget.flashcardGroup.flashcards.where((card) => card.status == 'memorized').length.toString(), Colors.green),
                _buildStatCard('Not Memorized', widget.flashcardGroup.flashcards.where((card) => card.status == 'not memorized').length.toString(), Colors.red),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.flashcardGroup.flashcards.length,
              itemBuilder: (context, index) {
                Flashcard flashcard = widget.flashcardGroup.flashcards[index];
                Color statusColor = flashcard.status == 'memorized' ? Colors.green : Colors.red;

                return Card(
                  elevation: 2,
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 60,
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                flashcard.word,
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple[900]),
                              ),
                              SizedBox(height: 8),
                              Text(
                                flashcard.meaning,
                                style: TextStyle(fontSize: 16, color: Colors.deepPurple[700]),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(flashcard.isFavorite ? Icons.favorite : Icons.favorite_border, color: Colors.deepPurple),
                          onPressed: () {
                            _toggleFavorite(flashcard, index);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.deepPurple),
                          onPressed: () {
                            _showEditDialog(flashcard, index);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.deepPurple),
                          onPressed: () {
                            _deleteFlashcard(flashcard, index);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton('Add Card', Icons.add, Colors.deepPurple, () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AddCardDialog(
                        flashcardGroup: widget.flashcardGroup,
                        onFlashcardAdded: () {
                          setState(() {
                            _loadFlashcards();
                          });
                        },
                      );
                    },
                  );
                }),
                _buildActionButton('Practice', Icons.play_arrow, Colors.deepPurple, _startPractice),
                _buildActionButton('Swap', Icons.swap_horiz, Colors.deepPurple, _swapWordMeaning),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white),
          SizedBox(width: 8),
          Text(text, style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}