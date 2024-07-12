import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ms_prayer_times/data/data.dart';
import 'package:ms_prayer_times/data/location_services.dart';
import 'package:ms_prayer_times/widgets/prayers_widget.dart';
import 'package:ms_prayer_times/widgets/settings_page.dart';
import 'package:provider/provider.dart';

void main() async {
  initSettings().then((_) {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => PrayerTimesProvider()),
          ChangeNotifierProvider(create: (context) => SettingsModel())
        ],
        // Initialize the model in the builder. That way, Provider
        child: const PrayersApp(),
      ),
    );
  });
}

//initialize settings
Future<void> initSettings() async {
  await Settings.init();
  final country = Settings.getValue<String>('country');
  final city = Settings.getValue<String>('city');
  final calculationMethod = Settings.getValue<int>('calculation_method');
  final latitude = Settings.getValue<double>('latitude');
  final longitude = Settings.getValue<double>('longitude');
  if (country == null) {
    Settings.setValue<String>('country', 'england');
  }
  if (city == null) {
    Settings.setValue<String>('city', 'london');
  }
  if (calculationMethod == null) {
    Settings.setValue<int>('calculation_method', 1, notify: true);
  }
  if (latitude==null || longitude==null){
     //obtain the current position
        final locationService = LocationService();
        final Position position=await locationService.getCurrentLocation() ;
       // print('latitude is ${position.latitude}');
       Settings.setValue<double>('latitude', position.latitude);
       Settings.setValue<double>('longitude', position.longitude);
     
  }
}

class PrayersApp extends StatelessWidget {
  const PrayersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: PrayersHomePage(),
    );
  }
}

class PrayersHomePage extends StatefulWidget {
  const PrayersHomePage({
    super.key,
  });

  @override
  State<PrayersHomePage> createState() => _PrayersHomePageState();
}

class _PrayersHomePageState extends State<PrayersHomePage> {
  PrayerTimesProvider? _prayerTimesProvider;
  SettingsModel? _settings;

  @override
  Widget build(BuildContext context) {
    _settings = Provider.of<SettingsModel>(context);
    _prayerTimesProvider = Provider.of<PrayerTimesProvider>(context);

    //check for any prayers configurations updates
    // Check if the current prayer times configuration in settings is different
    // from the one stored in the PrayerTimesProvider.
    if (!_settings!.prayerTimesConfig
        .equals(_prayerTimesProvider!.prayerTimes.prayerTimesConfiguration)) {
      // If the configurations are different, update the configuration in the provider.
      _prayerTimesProvider?.setConfiguration(_settings!.prayerTimesConfig);
      //snapshot=_prayerTimesProvider!.fetchPrayerData() as AsyncSnapshot<Map<String, dynamic>>;
    }

    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
              //on pressed method for the settings button
              onPressed: () {
                //PrayerTimesConfig config=_prayerTimes.prayerTimesConfiguration;

                // _prayerTimesProvider?.setConfiguration(config);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AppSettings()));
              },
              icon: const Icon(Icons.menu))
        ],
      ),
      body: Center(
        child: PrayersWidget(
            prayerTimesProvider: _prayerTimesProvider,
            settingsModel: _settings),
      ),
    );
  }
}

//The Prayers widget contains the logic to display prayer times in a future builder
class PrayersWidget extends StatelessWidget {
  const PrayersWidget({
    super.key,
    required PrayerTimesProvider? prayerTimesProvider,
    SettingsModel? settingsModel,
  })  : _prayerTimesProvider = prayerTimesProvider,
        _settingsModel = settingsModel;

  final PrayerTimesProvider? _prayerTimesProvider;
  final SettingsModel? _settingsModel;
  
  @override
  Widget build(BuildContext context) {
    _prayerTimesProvider?.prayerTimes.prayerTimesConfiguration.latitude=
                    Settings.getValue<double>('latitude')!;
    _prayerTimesProvider?.prayerTimes.prayerTimesConfiguration.longitude=
                    Settings.getValue<double>('latitude')!;
    return FutureBuilder<Map<String, dynamic>>(
      future: _prayerTimesProvider?.fetchPrayerData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            final prayerData = snapshot.data;
            _prayerTimesProvider?.extractPrayerTimes(prayerData!);
            return prayerTimingsWidget(
                _prayerTimesProvider!.prayerTimes.prayersTimings,
                _settingsModel);
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
        }
        return const CircularProgressIndicator();
      },
    );
  }
}
