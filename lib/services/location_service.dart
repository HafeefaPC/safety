import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/constants.dart';

class LocationService {
  static Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status == PermissionStatus.granted;
  }
  
  static Future<bool> isLocationPermissionGranted() async {
    final status = await Permission.location.status;
    return status == PermissionStatus.granted;
  }
  
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }
  
  static Future<Position?> getCurrentLocation() async {
    try {
      // Check if location permission is granted
      if (!await isLocationPermissionGranted()) {
        final granted = await requestLocationPermission();
        if (!granted) {
          return null;
        }
      }
      
      // Check if location services are enabled
      if (!await isLocationServiceEnabled()) {
        return null;
      }
      
      // Get current position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: AppConstants.locationTimeoutSeconds),
        ),
      );
      
      return position;
    } catch (e) {
      return null;
    }
  }
  
  static String generateGoogleMapsUrl(double latitude, double longitude) {
    return 'https://www.google.com/maps?q=$latitude,$longitude';
  }
  
  static String generateLocationMessage(double latitude, double longitude) {
    final mapsUrl = generateGoogleMapsUrl(latitude, longitude);
    return '${AppConstants.emergencyLocationMessage}$mapsUrl';
  }
  
  static Future<String?> getLocationMessage() async {
    final position = await getCurrentLocation();
    if (position == null) {
      return null;
    }
    
    return generateLocationMessage(position.latitude, position.longitude);
  }
  
  static Future<double?> getDistanceFromLocation(
    double latitude, 
    double longitude, 
    double targetLatitude, 
    double targetLongitude
  ) async {
    try {
      final distance = Geolocator.distanceBetween(
        latitude,
        longitude,
        targetLatitude,
        targetLongitude,
      );
      return distance;
    } catch (e) {
      return null;
    }
  }
  
  static Future<void> openLocationSettings() async {
    try {
      await Geolocator.openLocationSettings();
    } catch (e) {
      // If Geolocator doesn't work, try opening app settings
      try {
        await Geolocator.openAppSettings();
      } catch (e2) {
        // If both fail, do nothing
      }
    }
  }
}
