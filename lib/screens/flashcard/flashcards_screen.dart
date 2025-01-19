import 'package:app/screens/flashcard/flashcard_review_screen.dart';
import 'package:app/screens/flashcard/practice_screen.dart';
import 'package:flutter/material.dart';
import 'package:flashcards_repo/flashcards_package.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FlashcardsScreen extends StatelessWidget {
  final FlashcardsService _flashcardsService = FlashcardsService();
  
  void _startPractice(BuildContext context, FlashcardGroup flashcardGroup) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PracticeScreen(
          flashcardGroup: flashcardGroup,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Firebase kullanıcı bilgilerini alıyoruz
    String userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('Flashcard Set'),
        backgroundColor: Colors.deepPurple, // Koyu mor app bar
      ),
      body: StreamBuilder<List<FlashcardGroup>>(
        stream: _flashcardsService.getFlashcardGroupsStream(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No groups found'));
          } else {
            List<FlashcardGroup> groups = snapshot.data!;
            return ListView.builder(
              itemCount: groups.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.all(8),
                  color: Colors.purple[800], // Koyu mor card
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              groups[index].name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white, // Beyaz yazı
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.white), // Beyaz ikon
                              onPressed: () {
                                _flashcardsService.editGroup(
                                  context,
                                  userId,
                                  index,
                                  groups,
                                  () {},
                                );
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          groups[index].description,
                          style: TextStyle(fontSize: 14, color: Colors.white70), // Açık beyaz yazı
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            // Review sayfasına geçiş
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReviewScreen(
                                  flashcardGroup: groups[index], // Seçilen grubu review sayfasına gönder
                                ),
                              ),
                            );
                          },
                          child: Text('Review'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple, // Koyu mor buton
                          ),
                        ),
                        SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => _startPractice(context, groups[index]), // Pass flashcardGroup
                          child: Text('Practice'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple, // Koyu mor buton
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _flashcardsService.addGroup(
            context,
            userId,
            [],
            () {},
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.deepPurple, // Koyu mor FAB
      ),
    );
  }
}
