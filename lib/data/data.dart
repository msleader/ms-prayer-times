import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:http/http.dart' as http;
import 'prayer_times_config.dart';

//date
DateTime now = DateTime.now();

//Prayer Time Class
class PrayerTime {
  final String name;
  final String time;

  PrayerTime(this.name, this.time);

  @override
  String toString() => '$this.name:$this.time';
}

// Prayer times class containing all data
class PrayerTimes {
  //configurations
  PrayerTimesConfig _prayerTimesConfig =
      PrayerTimesConfig(
      latitude: 51.508515, 
      longitude: -0.1254872, 
      method: Settings.getValue<int>('calculation_method')!,
      city: Settings.getValue<String>('city')!,
      country: Settings.getValue<String>('country')!
      );
  //timings
  late List<PrayerTime> _prayerTimesTimings;
  //constructor
  PrayerTimes();
  //set config
  void updateConfig(PrayerTimesConfig config) {
    _prayerTimesConfig = config;
  }

  //get config
  PrayerTimesConfig get prayerTimesConfiguration => _prayerTimesConfig;

  //get prayer timings
  List<PrayerTime> get prayersTimings => _prayerTimesTimings;
}

//Prayer Service
class PrayerService {
  static Future<Map<String, dynamic>> getPrayerTimesData(
      PrayerTimesConfig prayerTimesconfig,{int getMethod=0}) async {

       
    const baseUrlByLatLong = 'https://api.aladhan.com/v1/timings/';
    const baseUrlByCity='https://api.aladhan.com/v1/timingsByCity/';
    final date = '${now.day}-${now.month}-${now.year}';
    final latitudeConfig = '?latitude=${prayerTimesconfig.latitude}';
    final longitudeConfig = '&longitude=${prayerTimesconfig.longitude}';
    final methodConfig = '&method=${prayerTimesconfig.method}';
    final cityConfig='?city=${prayerTimesconfig.city.replaceAll(' ', '+')}';
    final country = '&country=${prayerTimesconfig.country.replaceAll(' ', '+')}';
    final url =getMethod==0?
        baseUrlByLatLong + date + latitudeConfig + longitudeConfig + methodConfig:
        baseUrlByCity + date + cityConfig+country + methodConfig;

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      //print('the date that i want is $url');
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data;
    } else {
      throw Exception('Failed to get prayer times $url');
    }
  }
}

//Prayer times provider
class PrayerTimesProvider with ChangeNotifier {
  PrayerTimes prayerTimes = PrayerTimes();

  void setConfiguration(PrayerTimesConfig config) {
    prayerTimes.updateConfig(config);
  }

// Extracting Prayer Times (Optional):
  void extractPrayerTimes(Map<String, dynamic> prayerData) {
    final prayerTimesMap =
        prayerData['data']['timings'] as Map<String, dynamic>;
    prayerTimes._prayerTimesTimings = prayerTimesMap.entries
        .map((entry) => PrayerTime(entry.key, entry.value))
        .toList();
  }

  Future<Map<String, dynamic>> fetchPrayerData() async {
    return PrayerService.getPrayerTimesData(prayerTimes._prayerTimesConfig);
  }
}
