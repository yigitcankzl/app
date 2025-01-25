import 'package:flutter/material.dart';
import 'package:app/screens/quiz/quiz_questions_screen.dart';
import 'package:quiz_repo/quiz_package.dart';

class QuizListPage extends StatefulWidget {
  @override
  _QuizListPageState createState() => _QuizListPageState();
}

class _QuizListPageState extends State<QuizListPage> {
  void _showAddQuizDialog() {
    final _titleController = TextEditingController();
    final _descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Quiz'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Quiz Title'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Quiz Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Add the quiz
                QuizListService.addQuiz(
                  _titleController.text,
                  _descriptionController.text,
                  context,
                );
                Navigator.pop(context); // Close the dialog
                setState(() {}); // Update the ListView
              },
              child: const Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showEditQuizDialog(int index) {
    final _titleController = TextEditingController(text: QuizListService.quizzes[index]['title']);
    final _descriptionController = TextEditingController(text: QuizListService.quizzes[index]['description']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Quiz'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Quiz Title'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Quiz Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Update the quiz
                QuizListService.updateQuiz(
                  index,
                  _titleController.text,
                  _descriptionController.text,
                  context,
                );
                Navigator.pop(context); // Close the dialog
                setState(() {}); // Update the ListView
              },
              child: const Text('Update'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteQuizDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Quiz'),
          content: const Text('Are you sure you want to delete this quiz?'),
          actions: [
            TextButton(
              onPressed: () {
                // Delete the quiz
                QuizListService.deleteQuiz(index, context);
                Navigator.pop(context); // Close the dialog
                setState(() {}); // Update the ListView
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quizzes')),
      body: ListView.builder(
        itemCount: QuizListService.quizzes.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(QuizListService.quizzes[index]['title']!),
            subtitle: Text(QuizListService.quizzes[index]['description']!),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuizQuestionPage(quizTitle: QuizListService.quizzes[index]['title']!),
                ),
              );
            },
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    _showEditQuizDialog(index); // Edit quiz
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    _showDeleteQuizDialog(index); // Delete quiz
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddQuizDialog, // Open pop-up form
        child: const Icon(Icons.add),
      ),
    );
  }
}
