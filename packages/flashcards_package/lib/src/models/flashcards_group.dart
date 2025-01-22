import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flashcards_repo/src/models/flashcard.dart';

class FlashcardGroup {
  String? id;
  String name;
  String description;
  List<Flashcard> flashcards;
  int memorizedCount;
  int notMemorizedCount;

  FlashcardGroup({
    this.id,
    required this.name,
    required this.description,
    this.flashcards = const [],
    this.memorizedCount = 0,
    this.notMemorizedCount = 0,
  });

  factory FlashcardGroup.fromFirestore(Map<String, dynamic> data, String documentId) {
    var flashcardsData = data['flashcards'] as List<dynamic>? ?? [];
    
    List<Flashcard> flashcards = flashcardsData.map((flashcardData) {
      return Flashcard.fromFirestore(flashcardData, documentId);
    }).toList();

    return FlashcardGroup(
      id: documentId,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      flashcards: flashcards,
      memorizedCount: flashcards.where((fc) => fc.status == 'memorized').length,
      notMemorizedCount: flashcards.where((fc) => fc.status == 'not memorized').length,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'flashcards': flashcards.map((fc) => fc.toFirestore()).toList(),
    };
  }

  Future<void> addGroupForUser(String userId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('flashcard_groups')
        .add(toFirestore());
  }
}