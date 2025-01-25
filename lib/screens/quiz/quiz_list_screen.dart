import 'package:flutter/material.dart';
import 'package:app/screens/quiz/quiz_questions_screen.dart';
import 'package:quiz_repo/quiz_package.dart';

class QuizListPage extends StatefulWidget {
  @override
  _QuizListPageState createState() => _QuizListPageState();
}

class _QuizListPageState extends State<QuizListPage> {
  void _showAddQuizBottomSheet() {
    final _titleController = TextEditingController();
    final _descriptionController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16.0,
            right: 16.0,
            top: 20.0,
          ),
          child: Column(
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      QuizListService.addQuiz(
                        _titleController.text,
                        _descriptionController.text,
                        context,
                      );
                      Navigator.pop(context);
                      setState(() {});
                    },
                    child: const Text('Add Your Own'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      //ai sayfasina gidecek
                    },
                    child: const Text('Add with ai'),
                  ),
                ],
              ),
            ],
          ),
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
                QuizListService.updateQuiz(
                  index,
                  _titleController.text,
                  _descriptionController.text,
                  context,
                );
                Navigator.pop(context);
                setState(() {});
              },
              child: const Text('Update'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
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
                QuizListService.deleteQuiz(index, context);
                Navigator.pop(context);
                setState(() {});
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
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
                    _showEditQuizDialog(index);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    _showDeleteQuizDialog(index);
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddQuizBottomSheet,
        child: const Icon(Icons.add),
      ),
    );
  }
}