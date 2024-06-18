import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() {
  // program starts executing here
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reiseoppleseren',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(255, 240, 255, 240)
      ),
      home: const SpeechScreen()
    );
  }
}

class SpeechScreen extends StatefulWidget {
  const SpeechScreen({super.key});

  @override
  _SpeechScreenState createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  late stt.SpeechToText _speech;
  final bool _isListening = false;
  final String _text = "Trykk på knappen for å snakke";
  final double _confidence = 1.0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _speech = stt.SpeechToText(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold (
      appBar: AppBar(
        title: const Text("Reiseoppleseren",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        backgroundColor: const Color.fromARGB(255, 0, 63, 14),
        foregroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 30.0),
            child: const Text(
              "Hvor skal du reise?",
              style: TextStyle(
                fontSize: 37, 
                fontWeight: FontWeight.bold
                ),
              )
          ),
          Expanded(
            child: Container(
              child: const Text(
                "Trykk på knappen for å snakke",
                style: TextStyle(
                  fontSize: 20, 
                  color: Colors.grey
                  )
              )
            )
          ),

          Container(
            padding: const EdgeInsets.fromLTRB(0,0,0,40.0),
            child: FloatingActionButton(
              onPressed: () {},
              backgroundColor: Colors.green,
              child: Icon(_isListening ? Icons.mic : Icons.mic_none),
            ),
          ),
      ])
    );
  }
}