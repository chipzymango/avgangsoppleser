String formatTimeToMins(String? dateTimeObject) {

  DateTime parsedDateTimeObject = DateTime.parse(dateTimeObject.toString());

  DateTime currentTime = DateTime.now();

  Duration difference = parsedDateTimeObject.difference(currentTime);

  int differenceInMins = difference.inMinutes;

  if (differenceInMins <= 0) {
    return "Nå";
  }
  else {
    return "${differenceInMins.toString()} min";
  }
}