import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String> fetchStopPlaceId(String query) async {

    String baseURL = "https://api.entur.io/geocoder/v1/autocomplete?";
    String requestURL = "${baseURL}text=$query&layers=venue";
    final queryParameters = {
    'text': query, // added boundaries to limit query to results within oslo only
    'layers': 'venue',
    'boundary.rect.min_lat': '59.81',  // Minimum latitude of Oslo
    'boundary.rect.min_lon': '10.55',  // Minimum longitude of Oslo
    'boundary.rect.max_lat': '60.00',  // Maximum latitude of Oslo
    'boundary.rect.max_lon': '10.95',  // Maximum longitude of Oslo
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
      print("response 1 body: \n${response.body}");
      String stopPlaceId = results["features"][0]["properties"]["id"];
      String stopPlaceName = results["features"][0]["properties"]["name"];
      print("stop Place Name: $stopPlaceName");

      return stopPlaceId;
    }
    else 
    {
        return "Request error: ${response.statusCode.toString()}";
    }
}

Future<Map<String, String?>> getStopPlaceProperties(String stopPlaceId, [String? routeNumber]) async {

  String requestURL = "https://api.entur.io/journey-planner/v3/graphql";

  String query = """
  {
    stopPlace(id: "$stopPlaceId") {
      id
      name
      estimatedCalls(timeRange: 72100, numberOfDepartures: 10) {
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
      'Content-Type': 'application/json; charset=UTF-8',
      'ET-Client-Name': 'chipzymango-departuresboard'
    },
    body: jsonEncode({'query': query})
  );

  if (response.statusCode == 200) {
    final results = jsonDecode(response.body);

    if (results["data"]["stopPlace"].toString() == "null") {
      return {"Error": "No stop places were found.."};
    }
    else {
      String? stopPlaceName = results["data"]["stopPlace"]["name"];
      List<dynamic> estimatedCalls = results["data"]["stopPlace"]["estimatedCalls"];

      if (routeNumber != null) {
        String? expectedArrivalTime = estimatedCalls.firstWhere(
          (i) => i["serviceJourney"]["journeyPattern"]["line"]["publicCode"] == routeNumber)["expectedArrivalTime"];
        return {
          "stopPlaceName": stopPlaceName,
          "nearestArrivalTime": expectedArrivalTime
        };
      }
      else { // if route number wasn't provided, return the nearest arrival time
        String? expectedArrivalTime = estimatedCalls[0]["expectedArrivalTime"];
        return {
        "stopPlaceName": stopPlaceName,
        "nearestArrivalTime": expectedArrivalTime
        };
      }
    }
  }
  else {
    return {"Error": response.statusCode.toString()};
  }
}