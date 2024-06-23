String formatTimeToMins(String? dateTimeObject) {
  DateTime parsedDateTimeObject = DateTime.parse(dateTimeObject.toString());

  String time = dateTimeObject.toString().split('T')[1].split("+")[0];

  DateTime currentTime = DateTime.now();

  Duration difference = parsedDateTimeObject.difference(currentTime);

  int differenceInMins = difference.inMinutes;

  if (differenceInMins <= 0) {
    return "Nå";
  }
  else if (differenceInMins <= 10) {
    return "om ${differenceInMins.toString()} min";
  }
  else {
    return "kl. ${time.substring(0,time.length - 3)}";
  }
  // no i won't do a fourth else statement which checks how many days there are left, screw that
}