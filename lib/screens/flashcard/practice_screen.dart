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
  bool isLoading = false; 

  void _updateFlashcardInGroup(Flashcard updatedFlashcard) async {
    setState(() {
      // Loading indicator'ı başlatıyoruz
      isLoading = true;
    });

    try {
      // Firestore'daki flashcard'ı güncelle
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

      // Firestore güncellemesi başarılı olduğunda, lokal veriyi de güncelle
      setState(() {
        int index = widget.flashcardGroup.flashcards
            .indexWhere((flashcard) => flashcard.id == updatedFlashcard.id);
        if (index != -1) {
          widget.flashcardGroup.flashcards[index] = updatedFlashcard;
        }
        // Yükleniyor durumunu kaldırıyoruz
        isLoading = false;
      });
    } catch (error) {
      // Hata durumunda yükleniyor göstergesi kaldırılır
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
        backgroundColor: Colors.deepPurple,
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
                        currentIndex--; // Bir önceki karta geçiş
                        isFront = true; // Ön yüzü göstermek için sıfırla
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
                        currentIndex++; // Bir sonraki karta geçiş
                        isFront = true; // Ön yüzü göstermek için sıfırla
                      } else {
                        Navigator.pop(context); // Son karta ulaşıldığında ana ekrana dön
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
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 250,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.deepPurple, Colors.purpleAccent],
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
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditFlashcardScreen(
                                  flashcard: currentFlashcard,
                                  onSave: _updateFlashcardInGroup,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),  
            // Action Buttons
            Column(
              children: [
                SizedBox(height: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: currentFlashcard.status == 'memorized' 
                        ? Colors.green 
                        : Colors.red, // Duruma göre renk
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      // Durumu tersine çevir
                      currentFlashcard.status = currentFlashcard.status == 'memorized'
                          ? 'not memorized'
                          : 'memorized';
                    });
                    _updateFlashcardStatus(currentFlashcard);
                  },
                  child: Text(
                    currentFlashcard.status == 'memorized' 
                        ? 'MEMORIZED' 
                        : 'NOT MEMORIZED', // Duruma göre metin
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
}


class EditFlashcardScreen extends StatefulWidget {
  final Flashcard flashcard;
  final Function(Flashcard) onSave;

  EditFlashcardScreen({required this.flashcard, required this.onSave});

  @override
  _EditFlashcardScreenState createState() => _EditFlashcardScreenState();
}

class _EditFlashcardScreenState extends State<EditFlashcardScreen> {
  late TextEditingController _wordController;
  late TextEditingController _meaningController;

  @override
  void initState() {
    super.initState();
    _wordController = TextEditingController(text: widget.flashcard.word);
    _meaningController = TextEditingController(text: widget.flashcard.meaning);
  }

  @override
  void dispose() {
    _wordController.dispose();
    _meaningController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Flashcard'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _wordController,
              decoration: InputDecoration(labelText: 'Word'),
            ),
            TextField(
              controller: _meaningController,
              decoration: InputDecoration(labelText: 'Meaning'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Flashcard updatedFlashcard = Flashcard(
                  id: widget.flashcard.id,
                  word: _wordController.text,
                  meaning: _meaningController.text,
                  status: widget.flashcard.status,
                );
                widget.onSave(updatedFlashcard);
                Navigator.pop(context);
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
