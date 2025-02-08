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
      _flashcardGroupsStream = _flashcardsService.getFlashcardGroupsStream(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flashcards', style: TextStyle(fontWeight: FontWeight.bold)),
        
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showTranslateSheet(context);
            },
            icon: const Icon(Icons.translate),
          ),
        ],
      ),
      body: StreamBuilder<List<FlashcardGroup>>(
        stream: _flashcardGroupsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('No flashcard sets found',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            );
          }

          List<FlashcardGroup> groups = snapshot.data!;

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 5,
                margin: EdgeInsets.only(bottom: 16),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  title: Text(
                    groups[index].name,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      groups[index].description,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ),
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blueAccent),
                        onPressed: () => _flashcardsService.editGroup(
                          context, userId, index, groups, refreshGroups),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _flashcardsService.deleteGroup(
                          context, userId, groups[index], refreshGroups),
                      ),
                    ],
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReviewScreen(flashcardGroup: groups[index]),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _flashcardsService.addGroup(context, userId, [], refreshGroups),
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
