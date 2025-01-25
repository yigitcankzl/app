import 'package:flashcards_repo/src/models/flashcard.dart';
import 'package:flutter/material.dart';
import 'package:flashcards_repo/flashcards_package.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FlashcardsService {
  // Returns a stream of flashcard groups
    Stream<List<FlashcardGroup>> getFlashcardGroupsStream(String userId) async* {
  if (userId == null) {
    print('User is not logged in');
    yield [];
    return;
  }

  await for (var snapshot in FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('flashcard_groups')
      .snapshots()) {
    List<FlashcardGroup> flashcardGroups = [];

    for (var doc in snapshot.docs) {
      // Create a flashcard group
      FlashcardGroup group = FlashcardGroup(
        id: doc.id,
        name: doc['name'],
        description: doc['description'],
        flashcards: [], // Initialize an empty list of flashcards
      );

      // Fetch flashcards for each group
      var flashcardsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('flashcard_groups')
          .doc(doc.id)
          .collection('flashcards')
          .get();

      List<Flashcard> loadedFlashcards = [];
      for (var flashcardDoc in flashcardsSnapshot.docs) {
        loadedFlashcards.add(
          Flashcard(
            id: flashcardDoc.id,
            word: flashcardDoc['word'],
            meaning: flashcardDoc['meaning'],
            status: flashcardDoc['status'],
            isFavorite: flashcardDoc['isFavorite'],
          ),
        );
      }

      // Update the group's flashcards
      group.flashcards = loadedFlashcards;

      // Add the group to the list
      flashcardGroups.add(group);
    }

    yield flashcardGroups;  // Yield the updated list of groups
  }
}


  Future<void> loadFlashcards(String userId, String groupId) async {
    if (userId == null) {
      print('User is not logged in');
      return;
    }

    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('flashcard_groups')
          .doc(groupId)
          .collection('flashcards')
          .get();

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

      // You can pass these flashcards back to your widget using setState or a callback
    } catch (error) {
      print('Error loading flashcards: $error');
    }
  }

  void editGroup(
    BuildContext context,
    String userId,  
    int index,
    List<FlashcardGroup> groups,
    Function onSave,
  ) {
    TextEditingController nameController = TextEditingController(text: groups[index].name);
    TextEditingController descriptionController = TextEditingController(text: groups[index].description);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Group'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Group Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Group Description'),
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
            TextButton(
              onPressed: () async {
                String updatedName = nameController.text;
                String updatedDescription = descriptionController.text;

                if (updatedName.isNotEmpty && updatedDescription.isNotEmpty) {
                  try {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .collection('flashcard_groups')
                        .doc(groups[index].id)
                        .update({
                      'name': updatedName,
                      'description': updatedDescription,
                    });

                    groups[index].name = updatedName;
                    groups[index].description = updatedDescription;
                    onSave();
                    Navigator.pop(context);
                  } catch (e) {
                    print('Error updating group: $e');
                  }
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void addGroup(
    BuildContext context,
    String userId,  
    List<FlashcardGroup> groups,
    Function onSave,
  ) {
    TextEditingController nameController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Group'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Group Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Group Description'),
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
            TextButton(
              onPressed: () async {
                String groupName = nameController.text;
                String groupDescription = descriptionController.text;

                if (groupName.isNotEmpty && groupDescription.isNotEmpty) {
                  try {
                    DocumentReference docRef = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .collection('flashcard_groups')
                        .add({
                      'name': groupName,
                      'description': groupDescription,
                    });

                    groups.add(FlashcardGroup(
                      id: docRef.id,  
                      name: groupName,
                      description: groupDescription,
                      flashcards: [],
                    ));

                    onSave();
                    Navigator.pop(context);
                  } catch (e) {
                    print('Error adding group: $e');
                  }
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void deleteGroup(
    BuildContext context,
    String userId, 
    FlashcardGroup group,  
    Function onDelete,  
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('flashcard_groups')
          .doc(group.id)  
          .delete();

      onDelete();
    } catch (e) {
      print('Error deleting group: $e');
    }
  }
}