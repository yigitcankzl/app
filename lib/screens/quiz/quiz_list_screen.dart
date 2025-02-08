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
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Quiz Title',
                  prefixIcon: Icon(Icons.title),
                ),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Quiz Description',
                  prefixIcon: Icon(Icons.description),
                ),
              ),
              SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      QuizListService.addQuiz(
                        _titleController.text,
                        _descriptionController.text,
                        context,
                      );
                      Navigator.pop(context);
                      setState(() {});
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Your Own'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to AI page
                    },
                    icon: const Icon(Icons.computer),
                    label: const Text('Add with AI'),
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
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Quiz Title',
                  prefixIcon: Icon(Icons.title),
                ),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Quiz Description',
                  prefixIcon: Icon(Icons.description),
                ),
              ),
            ],
          ),
          actions: [
            TextButton.icon(
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
              icon: const Icon(Icons.check),
              label: const Text('Update'),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.cancel),
              label: const Text('Cancel'),
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
            TextButton.icon(
              onPressed: () {
                QuizListService.deleteQuiz(index, context);
                Navigator.pop(context);
                setState(() {});
              },
              icon: const Icon(Icons.delete_forever),
              label: const Text('Yes'),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.cancel),
              label: const Text('No'),
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
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            elevation: 5.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: ListTile(
              title: Text(
                QuizListService.quizzes[index]['title']!,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
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
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      _showEditQuizDialog(index);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _showDeleteQuizDialog(index);
                    },
                  ),
                ],
              ),
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
