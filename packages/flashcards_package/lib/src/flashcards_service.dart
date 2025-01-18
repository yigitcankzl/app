import 'package:flutter/material.dart';
import 'package:flashcards_repo/flashcards_package.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FlashcardsService {
  // Kullanıcıya özel flashcard gruplarını dinler ve UI'yi günceller
  Stream<List<FlashcardGroup>> getFlashcardGroupsStream(String userId) {
    return FirebaseFirestore.instance
        .collection('users')  // Kullanıcıya özel koleksiyon
        .doc(userId)
        .collection('flashcard_groups')  // Kullanıcıya özel flashcard grupları
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return FlashcardGroup.fromFirestore(doc.data(), doc.id); // doc.id ile belge kimliği ekleniyor
      }).toList();
    });
  }

  // Kullanıcıya özel grup düzenleme işlemi
  void editGroup(
    BuildContext context,
    String userId,  // userId parametresi ekleniyor
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
              onPressed: () async {
                String updatedName = nameController.text;
                String updatedDescription = descriptionController.text;

                if (updatedName.isNotEmpty && updatedDescription.isNotEmpty) {
                  // Kullanıcıya özel flashcard grubunu güncelleme
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)  // Kullanıcı ID'sine göre işlem yapılıyor
                      .collection('flashcard_groups')
                      .doc(groups[index].id)  // Belge ID ile güncelleme
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

  // Kullanıcıya özel yeni grup ekleme
  void addGroup(
    BuildContext context,
    String userId,  // userId parametresi ekleniyor
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
              onPressed: () async {
                String groupName = nameController.text;
                String groupDescription = descriptionController.text;

                if (groupName.isNotEmpty && groupDescription.isNotEmpty) {
                  // Kullanıcıya özel yeni grup Firestore'a ekleniyor
                  DocumentReference docRef = await FirebaseFirestore.instance
                      .collection('users')  // Kullanıcıya özel koleksiyon
                      .doc(userId)  // Kullanıcı ID'si
                      .collection('flashcard_groups')  // Kullanıcıya özel flashcard grupları
                      .add({
                    'name': groupName,
                    'description': groupDescription,
                  });

                  // Firestore'dan eklenen grup ID'si alınıyor
                  groups.add(FlashcardGroup(
                    id: docRef.id,  // ID'si ekleniyor
                    name: groupName,
                    description: groupDescription,
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
