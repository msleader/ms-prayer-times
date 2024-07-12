import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:ms_prayer_times/data/prayer_times_config.dart';
import 'package:provider/provider.dart';
// Calculation Methods
const Map<int, String> methods = {
      0: 'Shia Ithna-Ashari',
      1: 'University of Islamic Sciences, Karachi',
      2: 'Islamic Society of North America',
      3: 'Muslim World League',
      4: 'Umm Al-Qura University, Makkah',
      5: 'Egyptian General Authority of Survey',
      7: 'Institute of Geophysics, University of Tehran',
      8: 'Gulf Region',
      9: 'Kuwait',
      10: 'Qatar',
      11: 'Majlis Ugama Islam Singapura, Singapore',
      12: 'Union Organization islamic de France',
      13: 'Diyanet İşleri Başkanlığı, Turkey',
      14: 'Spiritual Administration of Muslims of Russia',
    };
// Define a model class to manage settings
class SettingsModel extends ChangeNotifier {
  // Initialize the prayer times configuration with default values
  PrayerTimesConfig prayerTimesConfig = PrayerTimesConfig(
    latitude: Settings.getValue<double>('latitude')??51.508515,
    longitude:  Settings.getValue<double>('longitude')??-0.1254872,
    method: Settings.getValue('calculation_method') ?? 1,
    city: 'london',
    country: 'england',
  );

  // Flag to switch between 12-hour and 24-hour modes
  bool mode_12 = true;

  // Flag to enable AM-PM mode (if 12-hour mode is selected)
  bool modeAmPm = false;

  // Update the calculation method based on user selection
  void updateCalculationMethod(int method) {
    prayerTimesConfig.method = method;
   
    notifyListeners(); // Notify listeners when the setting changes
  }

  // Update the time mode (12-hour or 24-hour)
  void updateTimeMode(bool mode) {
    mode_12 = mode;
    notifyListeners();
  }

  // Update the AM-PM mode (if enabled)
  void updateAmPmmode(bool value) {
    modeAmPm = value;
    notifyListeners();
  }
}

// Settings screen widget
class AppSettings extends StatelessWidget {
  const AppSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final settings =
        Provider.of<SettingsModel>(context); // Access the SettingsModel
  
    return SettingsScreen(
      title: 'Settings',
      children: [
        // Dropdown menu for selecting calculation method
        DropDownSettingsTile<int>(
          title: 'Method',
          settingKey: 'calculation_method',
          values: methods,
          selected: settings.prayerTimesConfig.method,
          onChange: (value) {
            settings.updateCalculationMethod(value);
            Settings.setValue<int>('calculation_method', value);
          },
        ),
        // Checkbox for 12-hour mode
        CheckboxSettingsTile(
          title: '12-Hour Mode',
          defaultValue: true,
          settingKey: 'mode_12',
          onChange: (value) {
            settings.updateTimeMode(value);
          },
          childrenIfEnabled: [
            // Nested checkbox for AM-PM mode (if 12-hour mode is selected)
            CheckboxSettingsTile(
              title: 'AM-PM',
              settingKey: 'AM_PM_mode',
              defaultValue: false,
              onChange: (value) {
                settings.updateAmPmmode(value);
              },
            ),
          ],
        ),
      ],
    );
  }
}
