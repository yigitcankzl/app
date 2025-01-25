import 'package:app/screens/flashcard/flashcard_review_screen.dart';
import 'package:app/screens/home/home_screen.dart';
import 'package:app/screens/lingva/lingva_screen.dart';
import 'package:flutter/material.dart';
import 'package:flashcards_repo/flashcards_package.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FlashcardsScreen extends StatefulWidget {
  @override
  _FlashcardsScreenState createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> {
  final FlashcardsService _flashcardsService = FlashcardsService();
  late String userId;
  late Stream<List<FlashcardGroup>> _flashcardGroupsStream;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser!.uid;
    _flashcardGroupsStream = _flashcardsService.getFlashcardGroupsStream(userId);
  }

  void refreshGroups() {
    setState(() {
      // Refresh the groups after editing, deleting, or adding
      _flashcardGroupsStream = _flashcardsService.getFlashcardGroupsStream(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flashcard Set'),
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
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
          },
        ),
      ),
      body: StreamBuilder<List<FlashcardGroup>>(
        stream: _flashcardGroupsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No groups found'));
          } else {
            List<FlashcardGroup> groups = snapshot.data!;
            return Column(
              children: [
                // Review All Button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => ReviewScreen(
                      //       flashcardGroup: FlashcardGroup(
                      //         name: 'All Flashcards',
                      //         description: 'Review all flashcards from all groups',
                      //         flashcards: groups.expand((group) => group.flashcards).toList(),
                      //       ), 
                      //     ),
                      //   ),
                      // );
                    },
                    child: Text('Review All'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple, 
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: groups.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: EdgeInsets.all(8),
                        color: Colors.purple[800], 
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
                                      color: Colors.white, 
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit, color: Colors.white), 
                                        onPressed: () {
                                          _flashcardsService.editGroup(
                                            context,
                                            userId,
                                            index,
                                            groups,
                                            refreshGroups,
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete, color: Colors.white), 
                                        onPressed: () {
                                          _flashcardsService.deleteGroup(
                                            context,
                                            userId,
                                            groups[index],
                                            refreshGroups,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                groups[index].description,
                                style: TextStyle(fontSize: 14, color: Colors.white70), 
                              ),
                              SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ReviewScreen(
                                        flashcardGroup: groups[index], 
                                      ),
                                    ),
                                  );
                                },
                                child: Text('Review'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple, 
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
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
            refreshGroups,
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }
}
