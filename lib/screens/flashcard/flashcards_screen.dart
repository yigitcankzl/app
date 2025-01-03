import 'package:flutter/material.dart';
import 'package:flashcards_repo/flashcards_package.dart';


class FlashcardsScreen extends StatefulWidget {
  @override
  _FlashcardsScreenState createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> {
  List<FlashcardGroup> groups = [
    FlashcardGroup(name: 'Group 1', description: 'Description of Group 1'),
    FlashcardGroup(name: 'Group 2', description: 'Description of Group 2'),
    FlashcardGroup(name: 'Group 3', description: 'Description of Group 3'),
    FlashcardGroup(name: 'Group 4', description: 'Description of Group 4'),
    FlashcardGroup(name: 'Group 5', description: 'Description of Group 5'),
    FlashcardGroup(name: 'Group 6', description: 'Description of Group 6'),
    FlashcardGroup(name: 'Group 7', description: 'Description of Group 7'),
    FlashcardGroup(name: 'Group 8', description: 'Description of Group 8'),
    FlashcardGroup(name: 'Group 9', description: 'Description of Group 9'),
    FlashcardGroup(name: 'Group 10', description: 'Description of Group 10'),
  ];
  
  final FlashcardsService _flashcardsService = FlashcardsService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flashcard Set')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Tüm gruplar için Review işlemi
                  },
                  child: Text('Review All'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Tüm gruplar için Practice işlemi
                  },
                  child: Text('Practice All'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: groups.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              groups[index].name!,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                _flashcardsService.editGroup(
                                  context,
                                  index,
                                  groups,
                                  () {
                                    setState(() {}); 
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          groups[index].description!,
                          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            // Review işlemi
                          },
                          child: Text('Review'),
                        ),
                        SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            // Practice işlemi
                          },
                          child: Text('Practice'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                _flashcardsService.addGroup(
                  context,
                  groups,
                  () {
                    setState(() {});
                  },
                );
              },
              child: Text('Add Group'),
            ),
          ),
        ],
      ),
    );
  }
}

