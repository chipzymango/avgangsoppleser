import 'package:http/http.dart' as http;
import 'dart:convert';

// String textInput = "hvilken tidspunkt kommer 65B bussen på rødtvet";

// void main() async {
//   await findTransitEntities(textInput);
// }

Future<Map<String, dynamic>> findTransitEntities(String text) async {
  print("Getting model results..");
  String localhostEndpoint = "http://10.0.2.2:8000/recognize?text=$text";// local test server endpoint should be 10.0.2.2:8000 instead of localhost:8000 as AVD uses 10.0.2.2 as an alias to the host loopback interface (i.e) localhost
  String requestURL = localhostEndpoint;
  http.Response response = await http.post(
    Uri.parse(requestURL), 
    headers: {
      'accept': 'application/json',
      'Content-Type': 'application/json; charset=UTF-8'
    },
    body: jsonEncode({
        "text": text,
        "group_entities": false,
        "wait": true
    })
  );

  print(response.body);
  
  return jsonDecode(utf8.decode(response.bodyBytes));

  

  // if (response.statusCode == 200) {
  //   final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
    
  //   if (jsonResponse["result"].isNotEmpty) {
  //     print("Entities found:");
  //     for (var entity in jsonResponse["result"]) {
  //       print("Entity: ${entity['word']},\nentity group: ${entity['entity_group']},\nconfidence: ${entity["score"]}\n");
  //     }
  //   }
  //   else {
  //     print("No entities were found with the provided text");
  //   } 
  // }
  // else {
  //   print("HTTP request failed: ${response.statusCode}");
  // }
}

