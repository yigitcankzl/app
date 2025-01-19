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

  // Firestore verilerinden Flashcard oluşturma
  factory Flashcard.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Flashcard(
      id: documentId,
      word: data['word'] ?? '',
      meaning: data['meaning'] ?? '',
      status: data['status'] ?? 'not memorized', // Default status if not provided
      groupId: data['groupId'], // Can be null if not provided
      isFavorite: data['isFavorite'],
    );
  }

  // Flashcard'ı Firestore'a kaydetmek için
  Map<String, dynamic> toFirestore() {
    return {
      'word': word,
      'meaning': meaning,
      'status': status,
      'groupId': groupId,
      'isFavorite' : isFavorite,
    };
  }

  // Kullanıcıya ait Flashcard oluşturma
  Future<void> addFlashcardForUser(String userId, String groupId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users') // Collection for users
          .doc(userId) // Using userId to store in the correct user's document
          .collection('flashcard_groups') // Flashcard groups sub-collection
          .doc(groupId) // Using groupId to store the flashcards under the specific group
          .collection('flashcards') // Sub-collection for flashcards
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