import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'apiservice.dart';
import 'format_time.dart';
import 'package:nlp/nlp.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:location/location.dart';

String testQuery = "Når kommer 4B Romsås bussen til grorud";

Map <String, String> correctionMap = {
  "årsbråten": "åsbråten",
};

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
  String _text = testQuery;

  FlutterTts _flutterTts = FlutterTts();
  Map? _currentVoice;
  Location location = Location();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _speech = stt.SpeechToText(); 
    initTTS();
    requestLocation();
  }

  Future<LocationData?> requestLocation() async {
    bool _locationServiceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    // enable location services
    _locationServiceEnabled = await location.serviceEnabled();
    if (!_locationServiceEnabled) {
      _locationServiceEnabled = await location.requestService();
      if (!_locationServiceEnabled) {
        print("Location services couldn't be enabled");
        return null;
      }
    }

    // request location permissions
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        print("Permission for location services was denied");
        return null;
      }
    }

    print("Permissions have been granted, getting location data...");
    return await location.getLocation(); 
  }

  void initTTS() {
    _flutterTts.getVoices.then( (data) {
      try {
        List<Map> _voices = List<Map>.from(data);
        _voices =
        _voices.where((_voice) => _voice["name"].contains("no")).toList();
      setState(() {
        _currentVoice = _voices[7];
        setVoice(_currentVoice!);
      });
      
      }
      catch (e) {
        print("error: $e");
      }
    });
  }

  void setVoice(Map voice) {
    _flutterTts.setVoice({"name": voice["name"], "locale": voice["locale"]});
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
              padding: const EdgeInsets.all(25.0),
              child: const Text(
                'Finn ankomsttider i stoppesteder! \nF.eks. "Når kommer 4B Romsås på Grorud"',
                style: TextStyle(
                  fontSize: 20, 
                  color: Color.fromARGB(255, 75, 75, 75),
                  )
              )
            )
            
          ),
          Expanded(
            child: Text(
              _text, 
              style: const TextStyle(
                fontWeight: FontWeight.w700
                )
            )
          ),

          Container(
            padding: const EdgeInsets.fromLTRB(0,0,0,40.0),
            width: 120,
            height: 120,
            child: FloatingActionButton(
              onPressed: _listen ,
              backgroundColor: Colors.green,
              child: Icon(_isListening ? Icons.mic : Icons.mic_none, size: 30),
              shape: const CircleBorder(),
              
            ),
          ),
      ])
    );
  }

  // this is to be called when microphone button is pressed
  void _listen() async {
    if (!_isListening) {
      // handle getting the user location
      LocationData? locationData = await requestLocation();
      if (locationData == null) {
        setState(() => _text = "Kunne ikke hente posisjon. Sørg for at posisjonstjenester er aktivert og at de nødvendige tillatelsene er gitt.");
        _flutterTts.speak(_text);
        return;
      }
      else {
        setState(() => _text = locationData.toString());
        print(locationData);
      }

      // handle speech services
      bool available = await _speech.initialize( 
        onStatus: (val) => print('onStatus:$val'),
        onError: (val) => print('onStatus: $val'),
      ); // waiting for initialization of speech recognition services



      if (available) {
        setState(() => _isListening = true);
        _flutterTts.stop();
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
      setState(() => _text = "${stopPlaceProperties.values.first}");
      _flutterTts.speak(_text);
      
    }
    else {
      if (routeNumber != null &&routeName != null) {
        String response = "Nærmeste ankomst av rute $routeNumber mot $routeName er ${formatTimeToMins(stopPlaceProperties["nearestArrivalTime"])}";
        setState(() {
          _text = response;
        });
        _flutterTts.speak("Nærmeste ankomst er om. ${formatTimeToMins(stopPlaceProperties["nearestArrivalTime"])}");
      }
      else if (routeNumber != null) {
        String response = "Nærmeste ankomst av rute $routeNumber er ${formatTimeToMins(stopPlaceProperties["nearestArrivalTime"])}";
        setState(() {
          _text = response;
        });
        _flutterTts.speak("Nærmeste ankomst er om. ${formatTimeToMins(stopPlaceProperties["nearestArrivalTime"])}");
      }
      else if (routeName != null) {
        String response = "Nærmeste ankomst av ruten mot $routeName er ${formatTimeToMins(stopPlaceProperties["nearestArrivalTime"])}";
        setState(() {
          _text = response;
        });
        _flutterTts.speak("Nærmeste ankomst er om. ${formatTimeToMins(stopPlaceProperties["nearestArrivalTime"])}");
      }
      else {
        String response = "Nærmeste ankomst er ${formatTimeToMins(stopPlaceProperties["nearestArrivalTime"])}";
        setState(() {
          _text = response;
        });
        _flutterTts.speak("Nærmeste ankomst er om. ${formatTimeToMins(stopPlaceProperties["nearestArrivalTime"])}");
      }
    }
  }

  void _handleSpeech(String text) {
    final routeNumberPattern = RegExp(r'\b\d{1,3}[A-Za-z]?\b');
    final stopPlacePattern = RegExp(r'\b(?:stopp|holdeplass|stasjon|ved|på|til|i)\s+([\wæøåÆØÅ\s]+)', caseSensitive: false);
    final onlyRouteNamePattern = RegExp(r'kommer\s+([\wæøåÆØÅ\s]+?)\s*(?:på|til|ved|i|$)', caseSensitive: false);
    final routeNumberAndNamePattern = RegExp(r'(\d{1,3}[A-Za-z]?)\s+([\wæøåÆØÅ\s]+?)(?:\s+(på|til|ved|i|$))', caseSensitive: false);

    final routeNumberMatch = routeNumberPattern.firstMatch(text);
    final stopPlaceMatch = stopPlacePattern.firstMatch(text);
    final routeNameMatch = onlyRouteNamePattern.firstMatch(text);
    final routeNumberAndNamePatternMatch = routeNumberAndNamePattern.firstMatch(text);

    if (stopPlaceMatch != null) {
      String stopPlace = stopPlaceMatch.group(1)!.trim();
      if (routeNumberAndNamePatternMatch != null) {
        String routeNumber = routeNumberAndNamePatternMatch.group(1)!;
        String routeName = routeNumberAndNamePatternMatch.group(2)!.trim();

        updateStopPlace(stopPlace, routeNumber: routeNumber, routeName: routeName);
      } 
      else if (routeNumberMatch != null) {
        String routeNumber = routeNumberMatch.group(0)!;
        updateStopPlace(stopPlace, routeNumber: routeNumber);
      } 
      else if (routeNameMatch != null) {
        String routeName = routeNameMatch.group(1)!.trim();
        updateStopPlace(stopPlace, routeName: routeName);
      } 
      else {
        updateStopPlace(stopPlace);
      }
    } else {
      setState(() {
        _text = "Du har ikke nevnt noe stoppested. Hvilken holdeplass / stasjon skal ruten ankomme?";
      });
      _flutterTts.speak("Du har ikke nevnt navnet på noe stoppested");
      
    }
  }
}