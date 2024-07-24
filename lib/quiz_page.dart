import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flip_card/flip_card.dart';

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<DocumentSnapshot> _flashcards = [];
  int _currentIndex = 0;
  bool _isFlippable = false;
  String _userAnswer = '';
  String _message = '';
  int _correctAnswers = 0;
  int _totalAttempts = 0;
  bool _isCompleted = false;

  final TextEditingController _answerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchFlashcards();
  }

  Future<void> _fetchFlashcards() async {
    final QuerySnapshot result =
        await FirebaseFirestore.instance.collection('flashcards').get();
    setState(() {
      _flashcards = result.docs;
    });
  }

  void _nextFlashcard() {
    if (_currentIndex < _flashcards.length - 1) {
      setState(() {
        _currentIndex++;
        _isFlippable = false;
        _message = '';
        _answerController.clear();
      });
    } else {
      setState(() {
        _isCompleted = true;
      });
    }
  }

  void _checkAnswer() {
    setState(() {
      _isFlippable = true;
      _totalAttempts++;
      if (_userAnswer.trim().toLowerCase() ==
          _flashcards[_currentIndex]['answer'].trim().toLowerCase()) {
        _correctAnswers++;
        _message = 'Correct!';
      } else {
        _message = 'Wrong!';
      }
    });
  }

  void _showResults() {
    final double percentage = (_correctAnswers / _totalAttempts) * 100;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Congratulations!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          content: Text(
            'Congratulations! You have scored ${percentage.toStringAsFixed(2)}%.',
            style: TextStyle(
              fontSize: 18,
              color: Colors.black,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _currentIndex = 0;
                  _correctAnswers = 0;
                  _totalAttempts = 0;
                  _isCompleted = false;
                  _isFlippable = false;
                  _message = '';
                  _answerController.clear();
                });
              },
              child: Text(
                'Restart',
                style: TextStyle(
                  color: Colors.blueAccent,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Close',
                style: TextStyle(
                  color: Colors.blueAccent,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_flashcards.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Quiz'),
          backgroundColor: Colors.blueAccent,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final flashcard = _flashcards[_currentIndex];
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Quiz Time!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            FlipCard(
              direction: FlipDirection.HORIZONTAL,
              flipOnTouch: _isFlippable,
              front: Container(
                width: 250,
                height: 250,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    flashcard['question'],
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.black,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              back: Container(
                width: 250,
                height: 250,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    flashcard['answer'],
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.black,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _answerController,
              onChanged: (value) {
                setState(() {
                  _userAnswer = value;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Your Answer',
              ),
              enabled: !_isFlippable,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed:
                  !_isFlippable && _userAnswer.isNotEmpty ? _checkAnswer : null,
              child: Text('Check'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                elevation: 5,
              ),
            ),
            SizedBox(height: 20),
            Text(
              _message,
              style: TextStyle(
                color: _message == 'Correct!' ? Colors.green : Colors.red,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isCompleted ? _showResults : _nextFlashcard,
              child: Text(_isCompleted ? 'See Results' : 'Next Flashcard'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: _isCompleted ? Colors.orange : Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                elevation: 5,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Correct Answers: $_correctAnswers / $_totalAttempts',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
