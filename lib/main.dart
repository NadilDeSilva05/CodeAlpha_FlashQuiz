import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'welcome_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(FlashQuiz());
}

class FlashQuiz extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flashcard Quiz App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Raleway',
        textTheme: TextTheme(
          displayLarge: TextStyle(
            fontSize: 32.0,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 41, 0, 0),
          ),
          bodyLarge: TextStyle(
              fontSize: 18.0, color: const Color.fromARGB(255, 0, 0, 0)),
          bodyMedium: TextStyle(fontSize: 16.0, color: Colors.white70),
        ),
      ),
      home: WelcomePage(),
    );
  }
}
