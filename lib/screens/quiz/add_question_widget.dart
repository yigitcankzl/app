import 'package:flutter/material.dart';

class AddQuestionWidget extends StatelessWidget {
  final Function(Map<String, dynamic>?) onAdd;

  AddQuestionWidget({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: 'Multiple Choice'),
              Tab(text: 'True/False'),
              Tab(text: 'Text Input'),
              Tab(text: 'Matching'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                MultipleChoiceForm(onAdd: onAdd),
                TrueFalseForm(onAdd: onAdd),
                TextInputForm(onAdd: onAdd),
                MatchingForm(onAdd: onAdd),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MultipleChoiceForm extends StatefulWidget {
  final Function(Map<String, dynamic>?) onAdd;
  MultipleChoiceForm({required this.onAdd});

  @override
  _MultipleChoiceFormState createState() => _MultipleChoiceFormState();
}

class _MultipleChoiceFormState extends State<MultipleChoiceForm> {
  final TextEditingController questionController = TextEditingController();
  final TextEditingController optionAController = TextEditingController();
  final TextEditingController optionBController = TextEditingController();
  final TextEditingController optionCController = TextEditingController();
  final TextEditingController optionDController = TextEditingController();
  String correctAnswer = 'A';  // Set a default value

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextField(
            controller: questionController,
            decoration: InputDecoration(labelText: 'Question'),
          ),
          TextField(
            controller: optionAController,
            decoration: InputDecoration(labelText: 'Option A'),
          ),
          TextField(
            controller: optionBController,
            decoration: InputDecoration(labelText: 'Option B'),
          ),
          TextField(
            controller: optionCController,
            decoration: InputDecoration(labelText: 'Option C'),
          ),
          TextField(
            controller: optionDController,
            decoration: InputDecoration(labelText: 'Option D'),
          ),
          DropdownButton<String>(
            value: correctAnswer.isEmpty ? 'A' : correctAnswer,  // Default to 'A' if empty
            hint: Text('Select Correct Answer'),
            onChanged: (String? newValue) {
              setState(() {
                correctAnswer = newValue!;
              });
            },
            items: ['A', 'B', 'C', 'D']
                .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
          ),
          ElevatedButton(
            onPressed: () {
              widget.onAdd({
                'type': 'multiple_choice',
                'question': questionController.text,
                'options': {
                  'A': optionAController.text,
                  'B': optionBController.text,
                  'C': optionCController.text,
                  'D': optionDController.text,
                },
                'correct_answer': correctAnswer,
              });
            },
            child: Text('Add Question'),
          ),
        ],
      ),
    );
  }
}


class TrueFalseForm extends StatefulWidget {
  final Function(Map<String, dynamic>?) onAdd;
  TrueFalseForm({required this.onAdd});

  @override
  _TrueFalseFormState createState() => _TrueFalseFormState();
}

class _TrueFalseFormState extends State<TrueFalseForm> {
  final TextEditingController questionController = TextEditingController();
  String selectedAnswer = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextField(
            controller: questionController,
            decoration: InputDecoration(labelText: 'Question'),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedAnswer = 'True';
                  });
                },
                child: Text('True'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedAnswer == 'True' ? Colors.blue : Colors.grey,
                ),
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedAnswer = 'False';
                  });
                },
                child: Text('False'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedAnswer == 'False' ? Colors.blue : Colors.grey,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (selectedAnswer.isNotEmpty) {
                widget.onAdd({
                  'type': 'true_false',
                  'question': questionController.text,
                  'correct_answer': selectedAnswer,
                });
              }
            },
            child: Text('Add Question'),
          ),
        ],
      ),
    );
  }
}


class TextInputForm extends StatefulWidget {
  final Function(Map<String, dynamic>?) onAdd;
  TextInputForm({required this.onAdd});

  @override
  _TextInputFormState createState() => _TextInputFormState();
}

class _TextInputFormState extends State<TextInputForm> {
  final TextEditingController questionController = TextEditingController();
  final TextEditingController correctAnswerController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextField(
            controller: questionController,
            decoration: InputDecoration(labelText: 'Question'),
          ),
          TextField(
            controller: correctAnswerController,
            decoration: InputDecoration(labelText: 'Correct Answer'),
          ),
          ElevatedButton(
            onPressed: () {
              widget.onAdd({
                'type': 'text_input',
                'question': questionController.text,
                'correct_answer': correctAnswerController.text,
              });
            },
            child: Text('Add Question'),
          ),
        ],
      ),
    );
  }
}

class MatchingForm extends StatefulWidget {
  final Function(Map<String, dynamic>?) onAdd;
  MatchingForm({required this.onAdd});

  @override
  _MatchingFormState createState() => _MatchingFormState();
}

class _MatchingFormState extends State<MatchingForm> {
  final TextEditingController questionController = TextEditingController();
  final List<Map<String, String>> options = [
    {'left': '', 'right': ''},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextField(
            controller: questionController,
            decoration: InputDecoration(labelText: 'Question'),
          ),
          ListView.builder(
            shrinkWrap: true,
            itemCount: options.length,
            itemBuilder: (context, index) {
              return Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        options[index]['left'] = value;
                      },
                      decoration: InputDecoration(labelText: 'Left Option'),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        options[index]['right'] = value;
                      },
                      decoration: InputDecoration(labelText: 'Right Option'),
                    ),
                  ),
                ],
              );
            },
          ),
          ElevatedButton(
            onPressed: () {
              // Add a new pair of left and right options to the list
              setState(() {
                options.add({'left': '', 'right': ''});
              });
            },
            child: Text('Add Option'),
          ),
          ElevatedButton(
            onPressed: () {
              widget.onAdd({
                'type': 'matching',
                'question': questionController.text,
                'options': options,
              });
            },
            child: Text('Add Question'),
          ),
        ],
      ),
    );
  }
}
