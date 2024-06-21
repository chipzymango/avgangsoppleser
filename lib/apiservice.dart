import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String> fetchStopPlaceId(String query) async {

    String baseURL = "https://api.entur.io/geocoder/v1/autocomplete?";
    String requestURL = "${baseURL}text=${query}&layers=venue";
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
          'Accept': 'application/json'
        }
      );

    if (response.statusCode == 200) {
      final Map<String, dynamic> results = json.decode(response.body);
      String stopPlaceName = results["features"][0]["properties"]["name"];
      String stopPlaceId = results["features"][0]["properties"]["id"];

      print("Stoppested funnet: $stopPlaceName");
        return "Stop place: $stopPlaceName with id: $stopPlaceId was found!";
    }
    else 
    {
        print("Error.");
        return "Request error: ${response.statusCode.toString()}";
    }
}