import 'package:flutter/material.dart';

class QuizListService {
  static List<Map<String, String>> quizzes = [
    {
      'title': 'Quiz 1',
      'description': 'Bu quiz, temel Flutter bilgilerinizi test eder.',
    },
    {
      'title': 'Quiz 2',
      'description': 'Bu quiz, mobil uygulama geliştirme konusundaki bilginizi ölçer.',
    },
    {
      'title': 'Quiz 3',
      'description': 'Bu quiz, yapay zeka ve makine öğrenmesi hakkındaki bilginizi test eder.',
    },
  ];

  static void addQuiz(String title, String description, BuildContext context) {
    quizzes.add({
      'title': title,
      'description': description,
    });
  }

  static void updateQuiz(int index, String title, String description, BuildContext context) {
    quizzes[index] = {
      'title': title,
      'description': description,
    };
  }

  static void deleteQuiz(int index, BuildContext context) {
    quizzes.removeAt(index);
  }
}
