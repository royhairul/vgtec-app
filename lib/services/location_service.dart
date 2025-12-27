import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// Service untuk mendapatkan lokasi GPS
class LocationService {
  static final LocationService instance = LocationService._();
  LocationService._();

  /// Check apakah location service enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check permission status
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request permission
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Get current position dengan error handling
  Future<Position?> getCurrentPosition() async {
    try {
      // Check jika service enabled
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('⚠️ Location service is disabled');
        return null;
      }

      // Check permission
      LocationPermission permission = await checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await requestPermission();
        if (permission == LocationPermission.denied) {
          print('⚠️ Location permission denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('⚠️ Location permission denied forever');
        return null;
      }

      // Get position
      print('📍 Getting current position...');
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );

      print('✅ Position: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      print('❌ Error getting position: $e');
      return null;
    }
  }

  /// Get address dari coordinates
  Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return '${place.street}, ${place.subLocality}, ${place.locality}';
      }
      return null;
    } catch (e) {
      print('❌ Error getting address: $e');
      return null;
    }
  }

  /// Watch position stream (untuk live tracking)
  Stream<Position> watchPosition() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }
}
