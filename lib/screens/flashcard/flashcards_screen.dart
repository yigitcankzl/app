import 'package:app/screens/flashcard/flashcard_review_screen.dart';
import 'package:flutter/material.dart';
import 'package:flashcards_repo/flashcards_package.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FlashcardsScreen extends StatelessWidget {
  final FlashcardsService _flashcardsService = FlashcardsService();

  @override
  Widget build(BuildContext context) {
    // Firebase kullanıcı bilgilerini alıyoruz
    String userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: Text('Flashcard Set')),
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
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit),
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
                          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            // Navigate to the Review page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReviewScreen(
                                  flashcardGroup: groups[index], // Pass the selected group to the review page
                                ),
                              ),
                            );
                          },
                          child: Text('Review'),
                        ),
                        SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            // Practice işlemi
                          },
                          child: Text('Practice'),
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
      ),
    );
  }
}
