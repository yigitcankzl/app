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
              isFavorite: doc['isFavorite'], // Fetch the isFavorite status
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
          backgroundColor: Colors.deepPurple[100],
          title: Text('Edit Flashcard', style: TextStyle(color: Colors.deepPurple[900])),
          content: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _wordController,
                  decoration: InputDecoration(
                    labelText: 'Word',
                    labelStyle: TextStyle(color: Colors.deepPurple[800]),
                  ),
                ),
                TextFormField(
                  controller: _meaningController,
                  decoration: InputDecoration(
                    labelText: 'Meaning',
                    labelStyle: TextStyle(color: Colors.deepPurple[800]),
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
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
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
        title: Text(
          '${widget.flashcardGroup.name} Review',
          style: TextStyle(color: Colors.white),
        ),
      ),
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
                  color: Colors.deepPurple[50],
                  margin: EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 60,
                          color: statusColor,
                        ),
                        SizedBox(width: 10),

                        Column(
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

                        Spacer(),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
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
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AddCardDialog(
                          flashcardGroup: widget.flashcardGroup,
                          onFlashcardAdded: () {
                            setState(() {
                              _loadFlashcards(); // Reload flashcards from Firebase
                            });
                            // Optional: Show success message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Flashcard added successfully!'),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                  child: Text('Add Card', style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                  onPressed: _startPractice,
                  child: Text('Practice', style: TextStyle(color: Colors.white)),
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

  void _addFlashcard() async {
    if (_formKey.currentState?.validate() ?? false) {
      String word = _wordController.text.trim();
      String meaning = _meaningController.text.trim();

      if (userId != null) {
        try {
          // First, create a new document reference
          DocumentReference flashcardRef = FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('flashcard_groups')
              .doc(widget.flashcardGroup.id)
              .collection('flashcards')
              .doc();

          // Create a new Flashcard object with the generated ID
          Flashcard newFlashcard = Flashcard(
            id: flashcardRef.id, // Use the generated document ID
            word: word,
            meaning: meaning,
            status: 'not memorized',
            isFavorite: false,
          );

          // Save to Firebase
          await flashcardRef.set({
            'id': flashcardRef.id,
            'word': word,
            'meaning': meaning,
            'status': 'not memorized',
            'isFavorite': false,
            'groupId': widget.flashcardGroup.id,
            'userId': userId,
          });

          // Update local state
          setState(() {
            widget.flashcardGroup.flashcards.add(newFlashcard);
          });

          // Call the callback to update parent widget
          widget.onFlashcardAdded();
          
          // Close the dialog
          Navigator.pop(context);
        } catch (error) {
          print('Error adding flashcard: $error');
          // Optionally show error message to user
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
