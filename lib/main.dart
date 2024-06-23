import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'apiservice.dart';
import 'format_time.dart';
import 'package:nlp/nlp.dart';

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
  bool _isListening = false;
  String _text = "Når kommer 60 bussen på kroklia";//"Når kommer 60 bussen på kroklia?";//"Jeg skal ta 25 bussen fra Bjerke til Årvoll";//"[Ord som blir sagt vises her]";

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
                "Trykk på knappen for å snakke\nF.eks. 'Når kommer 31 bussen på Tonsenhagen?'",
                style: TextStyle(
                  fontSize: 20, 
                  color: Colors.grey
                  )
              )
            )
          ),
          Expanded(
            child: Text(
              _text
            )
          ),

          Container(
            padding: const EdgeInsets.fromLTRB(0,0,0,40.0),
            child: FloatingActionButton(
              onPressed: _listen ,
              backgroundColor: Colors.green,
              child: Icon(_isListening ? Icons.mic : Icons.mic_none),
            ),
            
          ),
      ])
    );
  }

  // this is to be called when microphone button is pressed
  void _listen() async {
    if (!_isListening) { 
      bool available = await _speech.initialize( 
        onStatus: (val) => print('onStatus:$val'),
        onError: (val) => print('onStatus: $val'),
      ); // waiting for initialization of speech recognition services

      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords; // each recognized word in text
          })
        ); // starting speech to text session
      }
    }
    else {
      setState(() => _isListening = false);
      _handleSpeech(_text);
      _speech.stop();
    }
  }

  Future<void> updateStopPlace(String stopPlace, [String? routeNumber]) async {
    String stopPlaceId = await fetchStopPlaceId(stopPlace);
    Map<String, String?> stopPlaceProperties = await getStopPlaceProperties(stopPlaceId, routeNumber);
    if (stopPlaceProperties.keys.first == "Error") {
      setState(() => _text = "Error: ${stopPlaceProperties.values.first}");
    }
    else {
      if (routeNumber != null) {
        setState(() {
          String response = "Nærmeste ankomst av rute $routeNumber er ${formatTimeToMins(stopPlaceProperties["nearestArrivalTime"])}";
          _text = response;
        });
      }
      else {
        setState(() {
          String response = "Nærmeste ankomst er ${formatTimeToMins(stopPlaceProperties["nearestArrivalTime"])}";
          _text = response;
        });
      }
    }
  }

  void _handleSpeech(String text) {
    print("_text: $text");
    final busNumberPattern = RegExp(r'\d{1,3}');
    final stopPlacePattern = RegExp(r'\b(?:stopp|holdeplass|stasjon|ved|på|i)\s(\w+)', caseSensitive: false);

    final busNumberMatch = busNumberPattern.firstMatch(text);
    final stopPlaceMatch = stopPlacePattern.firstMatch(text);

    // try to extract bus number and stop place from the text
    if (stopPlaceMatch != null) {
      if (busNumberMatch != null) {
        String busNumber = busNumberMatch.group(0)!;
        String stopPlace = stopPlaceMatch.group(1)!;
        print("stopPlace and BusNUmber Match Found! :\nbusNumber: $busNumber\nstopPlace: $stopPlace");
        updateStopPlace(stopPlace, busNumber);
      }
      else {
        String stopPlace = stopPlaceMatch.group(1)!;
        print("stopPlace and Busnumber Match Found! :\nstopPlace: $stopPlace");
        updateStopPlace(stopPlace);
      }
    }
    else {
      setState(() {
        _text = "Klarte ikke å finne noe stoppested. \nPrøv å si det på en annen måte.";
      });
    }
    
  }
}