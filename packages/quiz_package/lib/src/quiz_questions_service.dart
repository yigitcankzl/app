import 'package:flutter/material.dart';

class QuestionService {
  List<Map<String, dynamic>> questions = [
    {
      'question': 'What is the capital of France?',
      'type': 'multiple_choice',
      'options': ['Paris', 'London', 'Berlin', 'Rome'],
      'correct_answer': 'Paris',
    },
    {
      'question': 'Enter your name:',
      'type': 'text_input',
      'options': [],
      'correct_answer': '',
    },
    {
      'question': 'Select the correct answer:',
      'type': 'multiple_choice',
      'options': ['True', 'False'],
      'correct_answer': 'True',
    },
  ];

  void addQuestion(Map<String, dynamic> newQuestion) {
    questions.add(newQuestion);
  }

  Future<void> showAddQuestionDialog(BuildContext context,
      TextEditingController questionController, {Function? onAdd}) {
    String selectedQuestionType = 'multiple_choice';
    String? correctAnswer;
    List<String> options = [];
    List<TextEditingController> optionControllers = [];

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Question'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                // Question type selection
                DropdownButton<String>(
                  value: selectedQuestionType,
                  onChanged: (value) {
                    selectedQuestionType = value!;
                    options.clear();
                    optionControllers.clear(); // Clear previous options
                  },
                  items: <String>['multiple_choice', 'text_input', 'true_false']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                SizedBox(height: 10),
                // Question input
                TextField(
                  controller: questionController,
                  decoration: InputDecoration(labelText: 'Enter Question'),
                ),
                SizedBox(height: 10),
                // If multiple-choice, show options
                if (selectedQuestionType == 'multiple_choice') ...[
                  Column(
                    children: [
                      ...options.map((option) {
                        int index = options.indexOf(option);
                        return TextField(
                          controller: optionControllers[index],
                          onChanged: (value) {
                            options[index] = value;
                          },
                          decoration: InputDecoration(labelText: 'Option ${index + 1}'),
                        );
                      }).toList(),
                      ElevatedButton(
                        onPressed: () {
                          optionControllers.add(TextEditingController());
                          options.add('');
                        },
                        child: Text('Add Option'),
                      ),
                      // Correct answer field
                      TextField(
                        onChanged: (value) {
                          correctAnswer = value;
                        },
                        decoration: InputDecoration(labelText: 'Correct Answer'),
                      ),
                    ],
                  ),
                ],
                // If text input question type
                if (selectedQuestionType == 'text_input') ...[
                  TextField(
                    decoration: InputDecoration(labelText: 'Your Answer'),
                  ),
                ],
                // If true/false question type
                if (selectedQuestionType == 'true_false') ...[
                  Column(
                    children: [
                      ListTile(
                        title: Text('True'),
                        leading: Radio<String>(
                          value: 'True',
                          groupValue: correctAnswer,
                          onChanged: (value) {
                            correctAnswer = value;
                          },
                        ),
                      ),
                      ListTile(
                        title: Text('False'),
                        leading: Radio<String>(
                          value: 'False',
                          groupValue: correctAnswer,
                          onChanged: (value) {
                            correctAnswer = value;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (questionController.text.isNotEmpty &&
                    (selectedQuestionType == 'text_input' ||
                        (options.isNotEmpty && correctAnswer != null))) {
                  Map<String, dynamic> newQuestion = {
                    'question': questionController.text,
                    'type': selectedQuestionType,
                    'options': options,
                    'correct_answer': correctAnswer,
                  };
                  if (onAdd != null) {
                    onAdd(newQuestion);
                  }
                  Navigator.pop(context);
                } else {
                  // Show error if inputs are incomplete
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Please fill all fields correctly.'),
                  ));
                }
              },
              child: Text('Add Question'),
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
