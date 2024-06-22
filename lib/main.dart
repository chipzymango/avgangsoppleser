import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'helpers.dart';
import 'apiservice.dart';

List<String> travelKeywords = [
  "fra", "til", "ved", "gjennom", "mot", "via", "forbi", "mellom", "langs",
    "ombord", "på", "av", "med", "utenfor", "innom", "over", "under", "innenfor",
    "reise", "tur", "retning", "destinasjon", "stopp", "holdeplass", "stasjon",
    "rute", "linje", "buss", "trikk", "t-bane", "tog", "båt", "fly", "transport",
    "skyss", "avgang", "ankomst", "reisemål", "sjåfør", "passasjer"
];

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
  String _text = "Når kommer 31 bussen på tonsenhagen?";//"Jeg skal ta 25 bussen fra Bjerke til Årvoll";//"[Ord som blir sagt vises her]";

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

  Future<void> updateStopPlace(String stopPlace) async {
    String stopPlaceId = await fetchStopPlaceId(stopPlace);
    Map<String, String> stopPlaceProperties = await getStopPlaceProperties(stopPlaceId);
    setState(() {
      _text = "Stop Place Name: ${stopPlaceProperties["stopPlaceName"]}\nNearest Arrival Time: ${stopPlaceProperties["nearestArrivalTime"]}";
    });
  }

  void _handleSpeech(String text) {
    // check for keywords
    List<String> keywords = findTravelRelatedWord(text.split(' '));
    
    // check for numbersr
    String number = findDigits(text);

    // check if it is a bus station name
    if (text.split(' ')[0].toLowerCase() == "når") {
      // anticipating the speech begins with "when", it'll perform a search to find departure times in a stop place
      String stopPlace = text.split(' ')[text.split(' ').length-1].toLowerCase();

      updateStopPlace(stopPlace);
    }
  }
}