import 'package:flutter/material.dart';
import 'package:flashcards_repo/flashcards_package.dart';

class FlashcardsService {
  void editGroup(
    BuildContext context,
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
                groups[index].name = nameController.text;
                groups[index].description = descriptionController.text;
                onSave(); 
                Navigator.pop(context);
                
              },
              child: Text('Save'),
              
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
