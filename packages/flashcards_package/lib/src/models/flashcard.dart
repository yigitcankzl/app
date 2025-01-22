import 'package:cloud_firestore/cloud_firestore.dart';

class Flashcard {
  String? id;

  String word;
  String meaning;
  String status;
  String? groupId;
  bool isFavorite; 

  Flashcard({
    this.id,

    required this.word,
    required this.meaning,
    required this.status,
    this.groupId,
    this.isFavorite = false, 
  });

  factory Flashcard.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Flashcard(
      id: documentId,
      word: data['word'] ?? '',
      meaning: data['meaning'] ?? '',
      status: data['status'] ?? 'not memorized', 
      groupId: data['groupId'], 
      isFavorite: data['isFavorite'],
    );
  }


  Map<String, dynamic> toFirestore() {
    return {
      'word': word,
      'meaning': meaning,
      'status': status,
      'groupId': groupId,
      'isFavorite' : isFavorite,
    };
  }

  Future<void> addFlashcardForUser(String userId, String groupId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users') 
          .doc(userId)
          .collection('flashcard_groups') 
          .doc(groupId) 
          .collection('flashcards') 
          .add({
            'word': word,
            'meaning': meaning,
            'status': status,
            'groupId': groupId,
            'isFavorite' : isFavorite,

          });
    } catch (e) {
      print('Error saving flashcard: $e');
    }
  }
}