import 'package:flutter/material.dart';
import 'package:flashcards_repo/flashcards_package.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FlashcardsService {
  Stream<List<FlashcardGroup>> getFlashcardGroupsStream(String userId) {
    return FirebaseFirestore.instance
        .collection('users') 
        .doc(userId)
        .collection('flashcard_groups')  
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return FlashcardGroup.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
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
                  ));

                  onSave();
                  Navigator.pop(context);
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
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('flashcard_groups')
        .doc(group.id)  
        .delete();

    onDelete();
  }
}
