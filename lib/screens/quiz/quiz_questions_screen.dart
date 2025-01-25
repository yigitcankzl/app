import 'package:flutter/material.dart';
import 'package:quiz_repo/quiz_package.dart';

class QuizQuestionPage extends StatefulWidget {
  final String quizTitle;

  QuizQuestionPage({required this.quizTitle});

  @override
  _QuizQuestionPageState createState() => _QuizQuestionPageState();
}

class _QuizQuestionPageState extends State<QuizQuestionPage> {
  final QuestionService _questionService = QuestionService();
  final TextEditingController _questionController = TextEditingController();
  String? _selectedOption;
  bool? _selectedAnswer; // For true/false questions

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.quizTitle)),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // List questions
            Expanded(
              child: ListView.builder(
                itemCount: _questionService.questions.length,
                itemBuilder: (context, index) {
                  var question = _questionService.questions[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: ListTile(
                        title: Text(question['question'] as String),
                        subtitle: _buildQuestionWidget(question, index),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Add Question Button
            ElevatedButton(
              onPressed: () {
                _showAddQuestionDialog(context);
              },
              child: Text('Add Question'),
            ),
            // Practice Button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PracticePage()),
                );
              },
              child: Text('Practice'),
            ),
          ],
        ),
      ),
    );
  }

  // This will show the Add Question dialog
  void _showAddQuestionDialog(BuildContext context) {
    _questionService.showAddQuestionDialog(context, _questionController, onAdd: (newQuestion) {
      if (newQuestion != null) {
        setState(() {
          _questionService.addQuestion(newQuestion);
        });
      }
    });
  }

  Widget _buildQuestionWidget(Map<String, dynamic> question, int index) {
    switch (question['type']) {
      case 'multiple_choice':
        var options = (question['options'] as List<String>);
        return Column(
          children: options.map<Widget>((option) {
            return ListTile(
              title: Text(option),
              leading: Radio<String>(
                value: option,
                groupValue: _selectedOption,
                onChanged: (value) {
                  setState(() {
                    _selectedOption = value;
                  });
                },
              ),
            );
          }).toList(),
        );
      case 'text_input':
        return TextField(
          controller: _questionController,
          decoration: InputDecoration(labelText: 'Your Answer'),
        );
      case 'true_false':
        return Column(
          children: [
            ListTile(
              title: Text('True'),
              leading: Radio<bool>(
                value: true,
                groupValue: _selectedAnswer,
                onChanged: (value) {
                  setState(() {
                    _selectedAnswer = value;
                  });
                },
              ),
            ),
            ListTile(
              title: Text('False'),
              leading: Radio<bool>(
                value: false,
                groupValue: _selectedAnswer,
                onChanged: (value) {
                  setState(() {
                    _selectedAnswer = value;
                  });
                },
              ),
            ),
          ],
        );
      default:
        return const Text('Unsupported question type');
    }
  }
}

class PracticePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Practice Mode')),
      body: Center(
        child: Text('This is the practice mode content.'),
      ),
    );
  }
}
