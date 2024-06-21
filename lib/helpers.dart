import 'main.dart';

String findDigits(String sentence) {
  List characters = sentence.split('');
  String numbersFound = "";
  for (var char in characters) {
    if (int.tryParse(char.toString()) != null) {
      numbersFound = numbersFound + char.toString();
      //print("Found number ${char.toString()}");
    }
  }
  return numbersFound;
}

List<String> findTravelRelatedWord(List<String> listOfWords) {
  List<String> keywordsFound = [];
  for (String word in listOfWords) {
    if (travelKeywords.contains(word)) {
      keywordsFound.add(word);
    }
  }

  // int length = keywordsFound.length;
  // print( "$length travel related words found: ");

  // for (String keyword in keywordsFound) {
  //   print(keyword);
  // }
  return keywordsFound;
}