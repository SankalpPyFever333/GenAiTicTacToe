import 'package:advanced_tic_tac_toe/gamescreen.dart';
import 'package:advanced_tic_tac_toe/genai.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");

  final apiKey = dotenv.env['APIKEY'];
  if (apiKey == null) {
    stderr.writeln(
        r'No $AIzaSyB8V5T6JwZgA7DclAszArD_Zu94EuhupJI environment variable');
    exit(1);
  }
  
  // initialize the app:
  final ai = TicTacToeAI(apiKey);

  runApp(MyApp(ai: ai,));
}

class MyApp extends StatelessWidget {
  final TicTacToeAI ai;
  const MyApp({super.key , required this.ai});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'tictactoe',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: GamesGridBorad(ai: ai,),
    );
  }
}
