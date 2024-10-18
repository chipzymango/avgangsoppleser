import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'apiservice.dart';
import 'format_time.dart';
import 'package:nlp/nlp.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:location/location.dart';
import 'query_recognition.dart';

String testQuery = "Når er det bussen mot ski næringspark kommer";

Map <String, String> correctionMap = {
  "årsbråten": "åsbråten",
  "femmeren": "5",
  "fireren": "4",
  "ferien": "4", // hvis den tar opp "ferien" istenenfor "fireren"
  "treeren": "3",
  "toeren": "2",
  "maurstuen": "majorstuen",
  "vestlig": "vestli",
  "vestlige": "vestli",
  "fyra": "4",
  "när": "når"
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

  final FlutterTts _flutterTts = FlutterTts();
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
    bool locationServiceEnabled;
    PermissionStatus permissionGranted;
    LocationData _locationData;

    // enable location services
    locationServiceEnabled = await location.serviceEnabled();
    if (!locationServiceEnabled) {
      locationServiceEnabled = await location.requestService();
      if (!locationServiceEnabled) {
        print("Location services couldn't be enabled");
        return null;
      }
    }

    // request location permissions
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
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
        List<Map> voices = List<Map>.from(data);
        voices =
        voices.where((voice) => voice["name"].contains("no")).toList();
      setState(() {
        _currentVoice = voices[7];
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
              shape: const CircleBorder(),
              child: Icon(_isListening ? Icons.mic : Icons.mic_none, size: 30),
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
      handleSpeech(_text);
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
      if (routeNumber != null && routeName != null) {
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

  void checkWithRegex(text) {
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
        print("Route number: $routeNumber");

        updateStopPlace(stopPlace, routeNumber: routeNumber, routeName: routeName);
      } 
      else if (routeNumberMatch != null) {
        String routeNumber = routeNumberMatch.group(0)!;
        updateStopPlace(stopPlace, routeNumber: routeNumber);
        print("Route number: $routeNumber");
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

  void handleSpeech(String text) async {
    Map<String, dynamic> entities = await findTransitEntities(text);
    String detectedRouteNumber = (entities["recognized_data"]["data"]["route_number"]).toString();
    String detectedRouteName = entities["recognized_data"]["data"]["route_name"];
    String detectedStopPlace = entities["recognized_data"]["data"]["stop_place"];
    print("Route Number: '$detectedRouteNumber' \nRoute Name: '$detectedRouteName' \nStop Place: '$detectedStopPlace'");

    // Map<String, String?> stopPlaceProperties = await getStopPlaceProperties(await fetchStopPlaceId(detectedStopPlace), routeNumber: detectedRouteNumber, routeName: detectedRouteName);
    // if (stopPlaceProperties.keys.first == "Error") {
    //   setState(() => _text = "${stopPlaceProperties.values.first}");
    //   print("Could not find any route with the queried route number and name");
    // }
    // use location data if stop place was not mentioned
    if (detectedStopPlace == "undefined") {
      LocationData? location = await requestLocation();
      // null check in case location was declined
      if (location != null) {
        String lat = "59.719344";
        String long = "10.833024";
        List<String> nearbyStopPlaceIds = await fetchStopPlacesIdsByCoords(lat, long);
        // check for the queried route number or route name in nearby stop places
        for (String stopPlaceId in nearbyStopPlaceIds) {
          Map<String, String?> stopPlaceProperties = await getStopPlaceProperties(stopPlaceId);
          print(stopPlaceId);
          if (detectedRouteNumber != "0" && detectedRouteName != "undefined") {
            stopPlaceProperties = await getStopPlaceProperties(stopPlaceId, routeNumber: detectedRouteNumber, routeName: detectedRouteName);
            print("Route name and route number is found");
          }
          else if (detectedRouteNumber != "0") {
            stopPlaceProperties = await getStopPlaceProperties(stopPlaceId, routeNumber: detectedRouteNumber);
            print("Route number is found");
          }
          else if (detectedRouteName != "undefined") {
            stopPlaceProperties = await getStopPlaceProperties(stopPlaceId, routeName: detectedRouteName);
            print("Route name is found");
          }
          else {
            print("route name and number was not found.");
          }
          
          // if route name was found in this nearby stop place
          if (stopPlaceProperties.keys.first != "Error") {
            print("Stop place with the queried route name / number was found!: ${stopPlaceProperties["stopPlaceName"]}");
            print("Nearest arrival time: ${formatTimeToMins(stopPlaceProperties["nearestArrivalTime"])}");
            break;
          }
        }
      }
    }

    else {
      print("Stop place query found, not using location data!.");
      Map<String, String?> stopPlaceProperties = await getStopPlaceProperties(await fetchStopPlaceId(detectedStopPlace), routeNumber: detectedRouteNumber, routeName: detectedRouteName);
      print(stopPlaceProperties);
      print("${stopPlaceProperties["stopPlaceName"]}: ${formatTimeToMins(stopPlaceProperties["nearestArrivalTime"])}");
    }
    checkWithRegex(text);
  }
}