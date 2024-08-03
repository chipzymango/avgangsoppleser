import 'package:flutter/material.dart';
import 'package:intl/number_symbols_data.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'apiservice.dart';
import 'format_time.dart';
import 'package:flutter_tts/flutter_tts.dart';

String testQuery = "Når kommer 4b romsås";

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
  late bool useLocationData;
  late String latitude;
  late String longitude;

  final FlutterTts _flutterTts = FlutterTts();
  Map? _currentVoice;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _speech = stt.SpeechToText(); 
    initTTS();
<<<<<<< HEAD
=======
    requestLocation();
  }



  Future<LocationData?> requestLocation() async {
    bool locationServiceEnabled;
    PermissionStatus permissionGranted;

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
>>>>>>> 1adb33f (utilizes location data)
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
<<<<<<< HEAD
            child: Text(
              _text, 
              style: TextStyle(
                fontWeight: FontWeight.w700
                )
=======
            child: Container(
              padding: const EdgeInsets.all(25.0),
              child: Text(
                _text, 
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 20.0
                  )
              ),
>>>>>>> 1adb33f (utilizes location data)
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
<<<<<<< HEAD
    if (!_isListening) { 
      bool available = await _speech.initialize( 
=======
    if (!_isListening) {
      // handle getting the user location
      LocationData? currentLocation = await requestLocation();
      if (currentLocation == null) {
        // couldn't get location data
        useLocationData = false;
        setState(() => _text = "Kunne ikke hente posisjon. Sørg for at posisjonstjenester er aktivert og at de nødvendige tillatelsene er gitt.");
        _flutterTts.speak(_text);
        return;
      }
      else {
        useLocationData = true;
        latitude = "59.9453713";//currentLocation.toString().split(",")[0].split(" ")[1];
        longitude = "10.8459554";//currentLocation.toString().split(",")[1].split(": ")[1].split(">")[0];
      }

      // handle speech services
      bool speechAvailable = await _speech.initialize( 
>>>>>>> 1adb33f (utilizes location data)
        onStatus: (val) => print('onStatus:$val'),
        onError: (val) => print('onStatus: $val'),
      ); // waiting for initialization of speech recognition services

<<<<<<< HEAD
      if (available) {
=======
      if (speechAvailable) {
>>>>>>> 1adb33f (utilizes location data)
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

  Future<void> getStopPlaceInfo(String stopPlaceName, {String? routeNumber, String? routeName}) async {
    String stopPlaceId = await fetchStopPlaceId(stopPlaceName);
    
    Map<String, String?> stopPlaceProperties = await getStopPlaceProperties(stopPlaceId, routeNumber: routeNumber, routeName: routeName);
    if (stopPlaceProperties.keys.first == "Error") {
      setState(() => _text = "${stopPlaceProperties.values.first}");
      _flutterTts.speak(_text);
      
    }
    else {
      if (routeNumber != null &&routeName != null) {
        String response = "Nærmeste ankomst av rute $routeNumber mot $routeName på ${stopPlaceProperties["stopPlaceName"]} er ${formatTimeToMins(stopPlaceProperties["nearestArrivalTime"])}";
        setState(() {
          _text = response;
        });
        _flutterTts.speak("Nærmeste ankomst er. ${formatTimeToMins(stopPlaceProperties["nearestArrivalTime"])}");
      }
      else if (routeNumber != null) {
        String response = "Nærmeste ankomst av rute $routeNumber på ${stopPlaceProperties["stopPlaceName"]}  er ${formatTimeToMins(stopPlaceProperties["nearestArrivalTime"])}";
        setState(() {
          _text = response;
        });
        _flutterTts.speak("Nærmeste ankomst er. ${formatTimeToMins(stopPlaceProperties["nearestArrivalTime"])}");
      }
      else if (routeName != null) {
        String response = "Nærmeste ankomst av ruten mot $routeName på ${stopPlaceProperties["stopPlaceName"]}  er ${formatTimeToMins(stopPlaceProperties["nearestArrivalTime"])}";
        setState(() {
          _text = response;
        });
        _flutterTts.speak("Nærmeste ankomst er. ${formatTimeToMins(stopPlaceProperties["nearestArrivalTime"])}");
      }
      else {
        String response = "Nærmeste ankomst på ${stopPlaceProperties["stopPlaceName"]}  er ${formatTimeToMins(stopPlaceProperties["nearestArrivalTime"])}";
        setState(() {
          _text = response;
        });
        _flutterTts.speak("Nærmeste ankomst er. ${formatTimeToMins(stopPlaceProperties["nearestArrivalTime"])}");
      }
    }
  }

  void checkNearbyStopPlaces(lat, lon, {String? routeNumber, String? routeName}) async {
    late bool foundResult;
    List<String> nearbyStopPlaceIds = await fetchStopPlacesIdsByCoords(lat, lon);
    for (String stopPlaceId in nearbyStopPlaceIds) {
      
      Map<String, String?> stopPlaceProperties = await getStopPlaceProperties(stopPlaceId, routeNumber: routeNumber, routeName: routeName);

      if (stopPlaceProperties.keys.first == "Error") {
        foundResult = false;
        continue;
        
      }
      else {
        if (routeNumber != null && routeName != null) {
          foundResult = true;
          String response = "Nærmeste ankomst av rute $routeNumber mot $routeName på ${stopPlaceProperties["stopPlaceName"]} er ${formatTimeToMins(stopPlaceProperties["nearestArrivalTime"])}";
          setState(() {
            _text = response;
          });
          _flutterTts.speak("Nærmeste ankomst er. ${formatTimeToMins(stopPlaceProperties["nearestArrivalTime"])}");
          break;
        }
        else if (routeNumber != null) {
          foundResult = true;
          String response = "Nærmeste ankomst av rute $routeNumber er ${formatTimeToMins(stopPlaceProperties["nearestArrivalTime"])}";
          setState(() {
            _text = response;
          });
          _flutterTts.speak("Nærmeste ankomst er. ${formatTimeToMins(stopPlaceProperties["nearestArrivalTime"])}");
          break;
        }
        else if (routeName != null) {
          foundResult = true;
          String response = "Nærmeste ankomst av ruten mot $routeName er ${formatTimeToMins(stopPlaceProperties["nearestArrivalTime"])}";
          setState(() {
            _text = response;
          });
          _flutterTts.speak("Nærmeste ankomst er. ${formatTimeToMins(stopPlaceProperties["nearestArrivalTime"])}");
          break;
        }
        else {
          foundResult = true;
          String response = "Nærmeste ankomst er ${formatTimeToMins(stopPlaceProperties["nearestArrivalTime"])}";
          setState(() {
            _text = response;
          });
          _flutterTts.speak("Nærmeste ankomst er. ${formatTimeToMins(stopPlaceProperties["nearestArrivalTime"])}");
          break;
        }
      }
    }

    if (foundResult == false) {
      String response = "Fant ingen slik rute i nære stoppesteder.";
      setState(() {
            _text = response;
      });
      _flutterTts.speak("Kunne ikke finne noen stoppesteder i nærheten");
    }
  }

  void _handleSpeech(String text) async {
  LocationData? currentLocation = await requestLocation();

  final routeNumberPattern = RegExp(r'\b\d{1,3}[A-Za-z]?\b');
  final stopPlacePattern = RegExp(r'\b(?:stopp|holdeplass|stasjon|ved|på|til|i)\s+([\wæøåÆØÅ\s]+)', caseSensitive: false);
  final onlyRouteNamePattern = RegExp(r'(?:kommer|går)\s+(?:til|mot|på|ved|i|forbi)?\s*([\wæøåÆØÅ\s]+)', caseSensitive: false);
  final routeNumberAndNamePattern = RegExp(r'(\d{1,3}[A-Za-z]?)\s+(?!bussen|trikken|toget)([\wæøåÆØÅ\s]+)', caseSensitive: false);
  final routeNameAndNumberPattern = RegExp(r'(?:kommer|ankommer|går)\s+([\wæøåÆØÅ\s]+)?\s*(?:til|mot|på|i|ved|forbi)?\s*(\d{1,3}[A-Za-z]?)', caseSensitive: false);

  final routeNumberMatch = routeNumberPattern.firstMatch(text);
  final stopPlaceMatch = stopPlacePattern.firstMatch(text);
  final routeNameMatch = onlyRouteNamePattern.firstMatch(text);
  final routeNumberAndNamePatternMatch = routeNumberAndNamePattern.firstMatch(text);
  final routeNameAndNumberPatternMatch = routeNameAndNumberPattern.firstMatch(text);

  if (stopPlaceMatch != null) {
    String stopPlaceName = stopPlaceMatch.group(1)!.trim();

    if (routeNumberAndNamePatternMatch != null) {
      String routeNumber = routeNumberAndNamePatternMatch.group(1)!;
      String routeName = routeNumberAndNamePatternMatch.group(2)!.trim();


      getStopPlaceInfo(stopPlaceName, routeNumber: routeNumber, routeName: routeName);
    } else if (routeNameAndNumberPatternMatch != null) {
      String routeName = routeNameAndNumberPatternMatch.group(1)!.trim();
      String routeNumber = routeNameAndNumberPatternMatch.group(2)!.trim();


      getStopPlaceInfo(stopPlaceName, routeNumber: routeNumber, routeName: routeName);
    } else if (routeNumberMatch != null) {
      String routeNumber = routeNumberMatch.group(0)!;
      getStopPlaceInfo(stopPlaceName, routeNumber: routeNumber);
    } else if (routeNameMatch != null) {
      String routeName = routeNameMatch.group(1)!.trim();
      getStopPlaceInfo(stopPlaceName, routeName: routeName);
    } else {
      getStopPlaceInfo(stopPlaceName);
    }
  } else if (useLocationData) {
    latitude = "59.9453713"; // Current location latitude (replace with actual value)
    longitude = "10.8459554"; // Current location longitude (replace with actual value)
    if (routeNumberAndNamePatternMatch != null) {
      String routeNumber = routeNumberAndNamePatternMatch.group(1)!;
      String routeName = routeNumberAndNamePatternMatch.group(2)!.trim();
      checkNearbyStopPlaces(latitude, longitude, routeNumber: routeNumber, routeName: routeName);

    } else if (routeNameAndNumberPatternMatch != null) {
      String routeName = routeNameAndNumberPatternMatch.group(1)!.trim();
      String routeNumber = routeNameAndNumberPatternMatch.group(2)!;
      checkNearbyStopPlaces(latitude, longitude, routeNumber: routeNumber, routeName: routeName);

    } else if (routeNumberMatch != null) {
      String routeNumber = routeNumberMatch.group(0)!;
      checkNearbyStopPlaces(latitude, longitude, routeNumber: routeNumber);

    } else if (routeNameMatch != null) {
      String routeName = routeNameMatch.group(1)!.trim();
      checkNearbyStopPlaces(latitude, longitude, routeName: routeName);

    } else {
      checkNearbyStopPlaces(latitude, longitude);
    }
  } else {
    setState(() {
      _text = "Posisjondata er ikke aktivert så stoppested må nevnes. Hvilken holdeplass / stasjon skal ruten ankomme?";
    });
    _flutterTts.speak("Du har ikke nevnt navnet på noe stoppested");
  }
}

}