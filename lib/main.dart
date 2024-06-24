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
  String _text = "hvilken tid kommer tonsenhagen på kroklia?";

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

  Future<void> updateStopPlace(String stopPlace, {String? routeNumber, String? routeName}) async {
    String stopPlaceId = await fetchStopPlaceId(stopPlace);
    Map<String, String?> stopPlaceProperties = await getStopPlaceProperties(stopPlaceId, routeNumber: routeNumber, routeName: routeName);
    if (stopPlaceProperties.keys.first == "Error") {
      setState(() => _text = "Error: ${stopPlaceProperties.values.first}");
    }
    else {
      if (routeNumber != null &&routeName != null) {
        String response = "Nærmeste ankomst av rute $routeNumber mot $routeName er ${formatTimeToMins(stopPlaceProperties["nearestArrivalTime"])}";
        setState(() {
          _text = response;
        });
      }
      else if (routeNumber != null) {
        String response = "Nærmeste ankomst av rute $routeNumber er ${formatTimeToMins(stopPlaceProperties["nearestArrivalTime"])}";
        setState(() {
          _text = response;
        });
      }
      else if (routeName != null) {
        String response = "Nærmeste ankomst av ruten mot $routeName er ${formatTimeToMins(stopPlaceProperties["nearestArrivalTime"])}";
        setState(() {
          _text = response;
        });
      }
      else {
        String response = "Nærmeste ankomst er ${formatTimeToMins(stopPlaceProperties["nearestArrivalTime"])}";
        setState(() {
          _text = response;
        });
      }
    }
  }

  void _handleSpeech(String text) {
    final routeNumberPattern = RegExp(r'\d{1,3}');
    final stopPlacePattern = RegExp(r'\b(?:stopp|holdeplass|stasjon|ved|på|til|i)\s([\wæøåÆØÅ]+)', caseSensitive: false);
    final onlyRouteNamePattern = RegExp(r'kommer\s+([\wæøåÆØÅ]+)', caseSensitive: false);
    final routeNumberAndNamePattern = RegExp(r'(\d{1,3})\s+(?!buss|bussen|t-banen|banen|båten|trikken)([\wæøåÆØÅ]+)');

    final routeNumberMatch = routeNumberPattern.firstMatch(text);
    final stopPlaceMatch = stopPlacePattern.firstMatch(text);
    final routeNameMatch = onlyRouteNamePattern.firstMatch(text);
    final routeNumberAndNamePatternMatch = routeNumberAndNamePattern.firstMatch(text);

    // try to extract bus number and stop place from the text
    if (stopPlaceMatch != null) {
      String stopPlace = stopPlaceMatch.group(1)!;
      if (routeNumberAndNamePatternMatch != null) {
        String routeNumber = routeNumberAndNamePatternMatch.group(1)!;
        String routeName = routeNumberAndNamePatternMatch.group(2)!;

        updateStopPlace(stopPlace, routeNumber: routeNumber, routeName: routeName);
      }
      else if (routeNumberMatch != null) {
        String routeNumber = routeNumberMatch.group(0)!;
        updateStopPlace(stopPlace, routeNumber: routeNumber);
      }
      else if (routeNameMatch != null) {
        String routeName = routeNameMatch.group(1)!;
        updateStopPlace(stopPlace, routeName: routeName);
      }
      else {
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