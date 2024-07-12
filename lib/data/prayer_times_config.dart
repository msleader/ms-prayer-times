class PrayerTimesConfig {
  double latitude;
  double longitude;
  int method;
  String city;
  String country;

  PrayerTimesConfig({
    required this.latitude,
    required this.longitude,
    required this.method,
    required this.city,
    required this.country,
    
  });

// method to check the equality of two configurations
  bool equals(PrayerTimesConfig other) {
    return (other.latitude == latitude &&
        other.longitude == longitude &&
        other.method == method && 
        city==city);
         }
}
