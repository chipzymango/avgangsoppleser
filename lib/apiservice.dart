import 'package:http/http.dart' as http;
import 'dart:convert';


Future<String> fetchStopPlaceId(String query) async {

    String baseURL = "https://api.entur.io/geocoder/v1/autocomplete?";
    String requestURL = "${baseURL}text=$query&layers=venue";
    final queryParameters = {
    'text': query, // added boundaries to limit query to results within oslo only
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
      String stopPlaceId = results["features"][0]["properties"]["id"];

      return stopPlaceId;
    }
    else 
    {
        return "Request error: ${response.statusCode.toString()}";
    }
}

Future<Map<String, String>> getStopPlaceProperties(String stopPlaceId) async {

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
    int amountOfDepartures = results["data"]["stopPlace"]["estimatedCalls"].length;
    print("${amountOfDepartures.toString()} departures found.");

    String stopPlaceName = results["data"]["stopPlace"]["name"];
    String expectedArrivalTime = results["data"]["stopPlace"]["estimatedCalls"][0]["expectedArrivalTime"];

    Map<String, String> stopPlaceProperties = {
      "stopPlaceName": stopPlaceName,
      "nearestArrivalTime": expectedArrivalTime
    };
    return stopPlaceProperties;
  }
  else {
    return {"Failed": response.statusCode.toString()};
  }
}