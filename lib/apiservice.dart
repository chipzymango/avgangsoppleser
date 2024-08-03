import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String> fetchStopPlaceId(String query) async {
  String baseURL = "https://api.entur.io/geocoder/v1/autocomplete?";
  String requestURL = "${baseURL}text=$query&layers=venue";
  final queryParameters = {
    'text': query, 
    'layers': 'venue',
    'boundary.rect.min_lat': '59.81', 
    'boundary.rect.min_lon': '10.55',
    'boundary.rect.max_lat': '60.00',
    'boundary.rect.max_lon': '10.95',
    'size': '10'
  };

  final response = await http.get(
    Uri.parse(requestURL).replace(queryParameters: queryParameters), headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'ET-Client-Name': 'chipzymango-departuresboard'
    }
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> results = json.decode(response.body);
    String stopPlaceId = results["features"][0]["properties"]["id"];
    return stopPlaceId;
  } else {
    return "Request error: ${response.statusCode.toString()}";
  }
}

Future<Map<String, String?>> getStopPlaceProperties(String stopPlaceId, {String? routeNumber, String? routeName}) async {
  String requestURL = "https://api.entur.io/journey-planner/v3/graphql";

  String query = """
  {
    stopPlace(id: "$stopPlaceId") {
      id
      name
      estimatedCalls(timeRange: 72100, numberOfDepartures: 100) {
        realtime
        aimedArrivalTime
        expectedArrivalTime
        destinationDisplay {
          frontText
        }
        serviceJourney {
          journeyPattern {
            line {
              id
              publicCode
              transportMode
            }
          }
        }
      }
    }
  }""";

  final response = await http.post(
    Uri.parse(requestURL),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=utf-8',
      'ET-Client-Name': 'chipzymango-departuresboard'
    },
    body: jsonEncode({'query': query})
  );

  if (response.statusCode == 200) {
    final results = jsonDecode(utf8.decode(response.bodyBytes));

    if (results["data"]["stopPlace"] == null) {
      return {"Error": "Ingen stoppesteder funnet"};
    } 
    else {
      String? stopPlaceName = results["data"]["stopPlace"]["name"];

      List<dynamic> estimatedCalls = results["data"]["stopPlace"]["estimatedCalls"];

      if (routeNumber != null && routeName != null) {
        if (routeName == "bussen" || routeName == "trikken") {
          return {"Error": "Angi retningen på ruta. For eksempel: 60 Tonsenhagen"};
        }
        if (routeName.contains("bussen")) {
          routeName = routeName.replaceAll(" bussen", "");
        }

        var matchingCall = estimatedCalls.firstWhere(
          (i) => 
            i["serviceJourney"]["journeyPattern"]["line"]["publicCode"].toString().trim().toLowerCase() == routeNumber.trim().toLowerCase() &&
            i["destinationDisplay"]["frontText"].toString().trim().toLowerCase().contains(routeName!.trim().toLowerCase()),
          orElse: () => null
        );

        if (matchingCall != null) {
          String? expectedArrivalTime = matchingCall["expectedArrivalTime"];
          return {
            "stopPlaceName": stopPlaceName,
            "nearestArrivalTime": expectedArrivalTime
          };
        } else {
          return {"Error": "Finner ingen rute med angitt rutenummer og rutenavn"};
        }

      } else if (routeNumber != null) {
        var matchingCall = estimatedCalls.firstWhere(
          (i) => i["serviceJourney"]["journeyPattern"]["line"]["publicCode"].toString().trim().toLowerCase() == routeNumber.trim().toLowerCase(),
          orElse: () => null
        );

        if (matchingCall != null) {
          String? expectedArrivalTime = matchingCall["expectedArrivalTime"];
          return {
            "stopPlaceName": stopPlaceName,
            "nearestArrivalTime": expectedArrivalTime
          };
        } else {
          return {"Error": "Finner ingen rute med angitt rutenummer"};
        }
      } else if (routeName != null) {

        if (routeName.contains("bussen")) {
          routeName = routeName.replaceAll(" bussen", "");
        }

        var matchingCall = estimatedCalls.firstWhere(
          (i) => i["destinationDisplay"]["frontText"].toString().trim().toLowerCase().contains(routeName!.trim().toLowerCase()),
          orElse: () => null
        );

        if (matchingCall != null) {
          String? expectedArrivalTime = matchingCall["expectedArrivalTime"];
          return {
            "stopPlaceName": stopPlaceName,
            "nearestArrivalTime": expectedArrivalTime
          };
        } else {
          return {"Error": "Finner ingen rute med angitt rutenavn"};
        }
      } else {
        // neither route name nor route number detected, so getting closest arrival time
        if (estimatedCalls.isNotEmpty) {
          String? expectedArrivalTime = estimatedCalls[0]["expectedArrivalTime"];
          return {
            "stopPlaceName": stopPlaceName,
            "nearestArrivalTime": expectedArrivalTime
          };
        } else {
          return {"Error": "Ingen estimert ankomsttid funnet"};
        }
      }
    }
  } else {
    return {"Error": response.statusCode.toString()};
  }
}

Future<List<String>> fetchStopPlacesIdsByCoords(String latitude, String longitude, {int amountOfStopPlaces = 5}) async {
  String baseURL = "https://api.entur.io/geocoder/v1/reverse?";
  String requestURL = "${baseURL}point.lat=$latitude&point.lon=$longitude&boundary.circle.radius=10&size=${amountOfStopPlaces.toString()}&layers=venue";

  List<String> stopPlaceIds = [];

  final response = await http.get(
    Uri.parse(requestURL), headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'ET-Client-Name': 'chipzymango-departuresboard'
    }
  );

  if (response.statusCode == 200) {
    
    final results = jsonDecode(utf8.decode(response.bodyBytes));
    List<dynamic> nearbyStopPlaces = results["features"];

    for (var stopPlace in nearbyStopPlaces) {
      String stopPlaceId = stopPlace["properties"]["id"];//.split(":")[2];
      stopPlaceIds.add(stopPlaceId);      
    }
    return stopPlaceIds;
  } 
  else {
    return ["Request error: ${response.statusCode.toString()}"];
  }
}