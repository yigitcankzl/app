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

  void addGroup(
  BuildContext context,
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
              if (nameController.text.isNotEmpty &&
                  descriptionController.text.isNotEmpty) {
                groups.add(FlashcardGroup(
                  name: nameController.text,
                  description: descriptionController.text,
                ));
                onSave();
                Navigator.pop(context);
              }
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
