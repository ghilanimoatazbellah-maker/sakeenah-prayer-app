import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/location_service.dart';

/// Predefined Algerian & Islamic cities with exact coordinates
class CityPreset {
  final String name;
  final String country;
  final double latitude;
  final double longitude;

  const CityPreset({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
  });
}

class LocationNotifier extends ChangeNotifier {
  static const _latKey = 'saved_location_lat';
  static const _lngKey = 'saved_location_lng';
  static const _nameKey = 'saved_location_name';
  static const _autoKey = 'saved_location_is_auto';

  // Touggourt, Algeria default
  static const double defaultLat = 33.1000;
  static const double defaultLng = 6.0667;
  static const String defaultLabel = 'توقرت';

  static const List<CityPreset> popularCities = [
    CityPreset(name: 'الجزائر العاصمة', country: 'الجزائر', latitude: 36.7538, longitude: 3.0588),
    CityPreset(name: 'توقرت', country: 'الجزائر', latitude: 33.1000, longitude: 6.0667),
    CityPreset(name: 'وهران', country: 'الجزائر', latitude: 35.6987, longitude: -0.6349),
    CityPreset(name: 'قسنطينة', country: 'الجزائر', latitude: 36.3650, longitude: 6.6147),
    CityPreset(name: 'سطيف', country: 'الجزائر', latitude: 36.1911, longitude: 5.4137),
    CityPreset(name: 'بجاية', country: 'الجزائر', latitude: 36.7500, longitude: 5.0667),
    CityPreset(name: 'عنابة', country: 'الجزائر', latitude: 36.9000, longitude: 7.7667),
    CityPreset(name: 'ورقلة', country: 'الجزائر', latitude: 31.9500, longitude: 5.3333),
    CityPreset(name: 'باتنة', country: 'الجزائر', latitude: 35.5559, longitude: 6.1741),
    CityPreset(name: 'تلمسان', country: 'الجزائر', latitude: 34.8783, longitude: -1.3150),
    CityPreset(name: 'تيزي وزو', country: 'الجزائر', latitude: 36.7118, longitude: 4.0459),
    CityPreset(name: 'مستغانم', country: 'الجزائر', latitude: 35.9333, longitude: 0.0833),
    CityPreset(name: 'مكة المكرمة', country: 'السعودية', latitude: 21.4225, longitude: 39.8262),
    CityPreset(name: 'المدينة المنورة', country: 'السعودية', latitude: 24.5247, longitude: 39.5692),
    CityPreset(name: 'القدس الشريف', country: 'فلسطين', latitude: 31.7683, longitude: 35.2137),
  ];

  double _latitude = defaultLat;
  double _longitude = defaultLng;
  String _locationLabel = defaultLabel;
  bool _isAutoGps = true;
  bool _isLoading = false;
  bool _isInitialized = false;

  double get latitude => _latitude;
  double get longitude => _longitude;
  String get locationLabel => _locationLabel;
  bool get isAutoGps => _isAutoGps;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  LocationNotifier() {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    if (_isInitialized) return;

    if (prefs.containsKey(_latKey)) {
      _latitude = prefs.getDouble(_latKey) ?? defaultLat;
      _longitude = prefs.getDouble(_lngKey) ?? defaultLng;
      _locationLabel = LocationService.cleanCityName(
          prefs.getString(_nameKey) ?? defaultLabel);
      _isAutoGps = prefs.getBool(_autoKey) ?? true;
    }
    _isInitialized = true;
    notifyListeners();

    if (_isAutoGps) {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        final pos = await LocationService.getLastKnownPosition();
        if (pos != null) {
          _latitude = pos.latitude;
          _longitude = pos.longitude;
          _locationLabel =
              await LocationService.getCityAndStateName(_latitude, _longitude);
          await _persist();
          notifyListeners();
        }
      }
    }
  }

  Future<bool> refreshGpsLocation() async {
    _isLoading = true;
    notifyListeners();

    try {
      final pos = await LocationService.getCurrentPosition();
      if (pos != null) {
        _isInitialized = true;
        _latitude = pos.latitude;
        _longitude = pos.longitude;
        _isAutoGps = true;
        _locationLabel =
            await LocationService.getCityAndStateName(_latitude, _longitude);

        await _persist();
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (_) {
      // Fallback
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> setManualLocation({
    required double lat,
    required double lng,
    required String name,
  }) async {
    _isInitialized = true;
    _latitude = lat;
    _longitude = lng;
    _locationLabel = LocationService.cleanCityName(name);
    _isAutoGps = false;
    _isLoading = false;

    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_latKey, _latitude);
    await prefs.setDouble(_lngKey, _longitude);
    await prefs.setString(_nameKey, _locationLabel);
    await prefs.setBool(_autoKey, _isAutoGps);
  }
}
