import 'package:app/screens/quiz/add_question_widget.dart';
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
  final Map<int, String?> _selectedOptions = {};
  final Map<int, bool?> _selectedAnswers = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.quizTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _questionService.questions.length,
                itemBuilder: (context, index) {
                  var question = _questionService.questions[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Card(
                      elevation: 4,
                      child: ListTile(
                        title: Text(
                          question['question'] as String,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: _buildQuestionWidget(question, index),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20), // Added spacing between buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Add Question Button
                ElevatedButton(
                  onPressed: () {
                    _showAddQuestionDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Colors.blueAccent, // Button color
                    shadowColor: Colors.blue.shade700, // Shadow color
                    elevation: 8, // Elevation for shadow
                  ),
                  child: Text(
                    'Add Question',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                SizedBox(width: 20), // Space between buttons
                // Practice Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PracticePage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Colors.greenAccent, // Button color
                    shadowColor: Colors.green.shade700, // Shadow color
                    elevation: 8, // Elevation for shadow
                  ),
                  child: Text(
                    'Practice',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddQuestionDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => AddQuestionWidget(
        onAdd: (newQuestion) {
          if (newQuestion != null) {
            setState(() {
              _questionService.addQuestion(newQuestion);
            });
          }
          Navigator.pop(context);
        },
      ),
    );
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
                groupValue: _selectedOptions[index],
                onChanged: (value) {
                  setState(() {
                    _selectedOptions[index] = value;
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
                groupValue: _selectedAnswers[index],
                onChanged: (value) {
                  setState(() {
                    _selectedAnswers[index] = value;
                  });
                },
              ),
            ),
            ListTile(
              title: Text('False'),
              leading: Radio<bool>(
                value: false,
                groupValue: _selectedAnswers[index],
                onChanged: (value) {
                  setState(() {
                    _selectedAnswers[index] = value;
                  });
                },
              ),
            ),
          ],
        );
      case 'matching':
        var options = (question['options'] as List<Map<String, String>>);
        List<String?> _selectedRightOptions = List.filled(options.length, null);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: options.asMap().entries.map<Widget>((entry) {
            int i = entry.key;
            var option = entry.value;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left box
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        option['left']!,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Icon(
                    Icons.arrow_forward,
                    size: 24,
                    color: Colors.blueAccent,
                  ),
                  SizedBox(width: 20),
                  // Right box (Dropdown)
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<String>(
                        hint: Text('Select'),
                        isExpanded: true,
                        value: _selectedRightOptions[i],
                        items: options
                            .where((opt) => !_selectedRightOptions.contains(opt['right']))
                            .map<DropdownMenuItem<String>>((option) {
                          return DropdownMenuItem<String>(
                            value: option['right'],
                            child: Text(option['right']!),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedRightOptions[i] = value;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
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
