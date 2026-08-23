import 'dart:async';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

/// Wraps geolocator to provide fast cached position, accurate fresh GPS,
/// clean single-name reverse geocoding, and manual city search.
class LocationService {
  static Future<Position?> getLastKnownPosition() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (_) {
      return null;
    }
  }

  static Future<Position?> getCurrentPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (_) {
      try {
        return await Geolocator.getLastKnownPosition();
      } catch (_) {
        return null;
      }
    }
  }

  /// Cleans redundant state/city prefixes to produce clean names like "وهران", "توقرت", "سطيف", "الجزائر"
  static String cleanCityName(String raw) {
    var cleaned = raw
        .replaceAll('ولاية', '')
        .replaceAll('Province', '')
        .replaceAll('Wilaya', '')
        .replaceAll('State of', '')
        .replaceAll('Governorate', '')
        .replaceAll('محافظة', '')
        .trim();

    // If it contains a comma e.g. "وهران، وهران" or "وهران، الجزائر"
    if (cleaned.contains('،') || cleaned.contains(',')) {
      final parts = cleaned.split(RegExp(r'[,،]')).map((p) => p.trim()).where((p) => p.isNotEmpty).toList();
      if (parts.isNotEmpty) {
        if (parts.length >= 2 && parts[0] == parts[1]) {
          return parts[0];
        }
        return parts[0];
      }
    }
    return cleaned.isNotEmpty ? cleaned : 'توقرت';
  }

  /// Searches for coordinates by city name
  static Future<({double lat, double lng, String name})?> searchCityByName(
      String query) async {
    try {
      final locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        final name = await getCityAndStateName(loc.latitude, loc.longitude);
        return (
          lat: loc.latitude,
          lng: loc.longitude,
          name: cleanCityName(name.isNotEmpty ? name : query),
        );
      }
    } catch (_) {
      // Offline fallback
    }
    return null;
  }

  /// Resolves coordinates into a clean single Arabic City/Wilaya name (e.g. "وهران", "توقرت", "سطيف").
  static Future<String> getCityAndStateName(
      double latitude, double longitude) async {
    try {
      final placemarks =
          await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final city = place.locality ??
            place.subAdministrativeArea ??
            place.subLocality ??
            place.name ??
            '';
        final state = place.administrativeArea ?? '';

        if (city.isNotEmpty) {
          return cleanCityName(city);
        } else if (state.isNotEmpty) {
          return cleanCityName(state);
        }
      }
    } catch (_) {
      // Fallback
    }
    return 'توقرت';
  }
}
