import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ms_prayer_times/data/data.dart';

TimeOfDay stringToTimeOfDay(String timeString) {
  
  final format = DateFormat.Hm();
  final dateTime = format.parse(timeString);
  
  return TimeOfDay.fromDateTime(dateTime);
}

String formatTime(TimeOfDay time,bool mode_12,[bool showAMPM=false]){
final formatString=!mode_12?'HH:mm':showAMPM?'hh:mm a':'hh:mm';
final dateTime=DateTime(now.year,now.month,now.day,time.hour,time.minute);
final formatted = DateFormat(formatString).format(dateTime);
return formatted;
}
