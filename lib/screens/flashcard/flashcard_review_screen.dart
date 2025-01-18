import 'package:app/screens/flashcard/practice_screen.dart';
import 'package:flutter/material.dart';
import 'package:flashcards_repo/flashcards_package.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flashcards_repo/src/models/flashcard.dart';

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
    _loadFlashcards();
  }

  void _loadFlashcards() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      FirebaseFirestore.instance
          .collection('users')  // Kullanıcı koleksiyonu
          .doc(userId)  // Kullanıcı kimliği ile belge
          .collection('flashcard_groups')  // Flashcard grupları koleksiyonu
          .doc(widget.flashcardGroup.id)  // Flashcard group ID'sine göre belge
          .collection('flashcards')  // Flashcard'lar koleksiyonu
          .get()  // Tüm flashcard'ları al
          .then((snapshot) {
        List<Flashcard> loadedFlashcards = [];
        for (var doc in snapshot.docs) {
          loadedFlashcards.add(
            Flashcard(
              id: doc.id,  // Assuming you have an ID field for each flashcard
              word: doc['word'],
              meaning: doc['meaning'],
              status: doc['status'],
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
      flashcard.isFavorite = !flashcard.isFavorite;  // Toggle the favorite status
    });

    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection('flashcard_groups')
        .doc(widget.flashcardGroup.id)
        .collection('flashcards')
        .doc(flashcard.id)
        .update({'isFavorite': flashcard.isFavorite})  // Update Firestore
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
          title: Text('Edit Flashcard'),
          content: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _wordController,
                  decoration: InputDecoration(labelText: 'Word'),
                ),
                TextFormField(
                  controller: _meaningController,
                  decoration: InputDecoration(labelText: 'Meaning'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);  // Close the dialog
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
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
              child: Text('Update'),
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
      appBar: AppBar(title: Text('${widget.flashcardGroup.name} Review')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total: ${widget.flashcardGroup.flashcards.length}'),
                Text('Memorized: ${widget.flashcardGroup.flashcards.where((card) => card.status == 'memorized').length}'),
                Text('Not Memorized: ${widget.flashcardGroup.flashcards.where((card) => card.status == 'not memorized').length}'),
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
                  margin: EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        // Memorized status on the left side, filling the height of the card
                        Container(
                          width: 8, // Set a fixed width for the status indicator
                          height: 60, // Set the height based on the card's height
                          color: statusColor,
                        ),
                        SizedBox(width: 10), // Space between the status and the text

                        // Flashcard word and meaning
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              flashcard.word,
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Text(
                              flashcard.meaning,
                              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                            ),
                          ],
                        ),

                        // Right side icons (Favorite, Edit, Delete)
                        Spacer(),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(flashcard.isFavorite ? Icons.favorite : Icons.favorite_border),
                              onPressed: () {
                                _toggleFavorite(flashcard, index);  // Toggle favorite status
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                _showEditDialog(flashcard, index);  // Show edit dialog
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                _deleteFlashcard(flashcard, index);  // Delete flashcard
                              },
                            ),
                          ],
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AddCardDialog(
                          flashcardGroup: widget.flashcardGroup,
                          onFlashcardAdded: () {
                            setState(() {
                              // Update UI after adding a new flashcard
                            });
                          },
                        );
                      },
                    );
                  },
                  child: Text('Add Card'),
                ),
                ElevatedButton(
                  onPressed: _startPractice,
                  child: Text('Practice'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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

  void _addFlashcard() {
    if (_formKey.currentState?.validate() ?? false) {
      String word = _wordController.text.trim();
      String meaning = _meaningController.text.trim();

      if (userId != null) {
        Flashcard newFlashcard = Flashcard(
          word: word,
          meaning: meaning,
          status: 'not memorized',
        );

        setState(() {
          widget.flashcardGroup.flashcards.add(newFlashcard);
        });

        FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('flashcard_groups')
            .doc(widget.flashcardGroup.id)
            .collection('flashcards')
            .add({
          'word': word,
          'meaning': meaning,
          'status': 'not memorized',
          'groupId': widget.flashcardGroup.id,
          'userId': userId,
        }).then((_) {
          widget.onFlashcardAdded();
          Navigator.pop(context);
        }).catchError((error) {
          print('Error adding flashcard: $error');
        });
      } else {
        print('User is not logged in');
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
            Navigator.pop(context);  // Close the dialog
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
