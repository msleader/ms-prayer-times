//Building the Prayer Times List:
import 'package:flutter/material.dart';
import 'package:ms_prayer_times/data/data.dart';
import 'package:ms_prayer_times/data/tools.dart';
import 'package:ms_prayer_times/widgets/settings_page.dart';

// Widget to display prayer timings in a list
Widget prayerTimingsWidget(
    List<PrayerTime> prayersTimings, SettingsModel? settings) {
  return ListView.builder(
    itemCount: 7, // Assuming there are 7 prayer timings (adjust as needed)
    itemBuilder: (context, index) {
      final prayerTime =
          prayersTimings[index]; // Get the prayer time at the current index
      return ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
                width: 100,
                child: Text(prayerTime.name)
                ), // Display the prayer name
            SizedBox(
              width: 100,
              child: Text(
                formatTime(
                  stringToTimeOfDay(prayerTime.time), // Convert prayer time string to TimeOfDay
                  settings!.mode_12, // Use 12-hour mode if true
                  settings.modeAmPm, // Display AM/PM if enabled
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
