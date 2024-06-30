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
    print("API Response: $results");

    if (results["data"]["stopPlace"].toString() == "null") {
      return {"Error": "No stop places were found.."};
    } else {
      String? stopPlaceName = results["data"]["stopPlace"]["name"];
      List<dynamic> estimatedCalls = results["data"]["stopPlace"]["estimatedCalls"];
      for (var call in estimatedCalls) {
        String frontText = call["destinationDisplay"]["frontText"];
        String publicCode = call["serviceJourney"]["journeyPattern"]["line"]["publicCode"];
        print("FrontText: $frontText, PublicCode: $publicCode");
      }

      if (routeNumber != null && routeName != null) {
        print("API SIDE: route number '$routeNumber' and route name '$routeName' detected");
        var matchingCall = estimatedCalls.firstWhere(
          (i) => 
            i["serviceJourney"]["journeyPattern"]["line"]["publicCode"].toString().trim().toLowerCase() == routeNumber.trim().toLowerCase() &&
            i["destinationDisplay"]["frontText"].toString().trim().toLowerCase().contains(routeName.trim().toLowerCase()),
          orElse: () => null
        );

        if (matchingCall != null) {
          print("Matching call found: $matchingCall");
          String? expectedArrivalTime = matchingCall["expectedArrivalTime"];
          return {
            "stopPlaceName": stopPlaceName,
            "nearestArrivalTime": expectedArrivalTime
          };
        } else {
          print("Matching call failed");
          return {"Error": "No routes with the specified route number and name were found"};
        }

      } else if (routeNumber != null) {
        print("API SIDE: route number '$routeNumber' detected");
        var matchingCall = estimatedCalls.firstWhere(
          (i) => i["serviceJourney"]["journeyPattern"]["line"]["publicCode"].toString().trim().toLowerCase() == routeNumber.trim().toLowerCase(),
          orElse: () => null
        );

        if (matchingCall != null) {
          print("Matching call found: $matchingCall");
          String? expectedArrivalTime = matchingCall["expectedArrivalTime"];
          return {
            "stopPlaceName": stopPlaceName,
            "nearestArrivalTime": expectedArrivalTime
          };
        } else {
          return {"Error": "No routes with the specified route number were found"};
        }
      } else if (routeName != null) {        
        print("API SIDE: route name '$routeName' detected");
        var matchingCall = estimatedCalls.firstWhere(
          (i) => i["destinationDisplay"]["frontText"].toString().trim().toLowerCase().contains(routeName.trim().toLowerCase()),
          orElse: () => null
        );

        if (matchingCall != null) {
          print("Matching call found: $matchingCall");
          String? expectedArrivalTime = matchingCall["expectedArrivalTime"];
          return {
            "stopPlaceName": stopPlaceName,
            "nearestArrivalTime": expectedArrivalTime
          };
        } else {
          return {"Error": "No routes with the specified route name were found"};
        }
      } else {
        print("API side: neither route name nor route number detected, so getting closest arrival time");
        String? expectedArrivalTime = estimatedCalls[0]["expectedArrivalTime"];
        return {
          "stopPlaceName": stopPlaceName,
          "nearestArrivalTime": expectedArrivalTime
        };
      }
    }
  } else {
    return {"Error": response.statusCode.toString()};
  }
}