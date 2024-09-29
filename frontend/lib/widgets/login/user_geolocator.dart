// geolocator_service.dart
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class GeolocatorService {
  static Future<Position> getCurrentPosition(
      {LocationAccuracy accuracy = LocationAccuracy.high}) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition(desiredAccuracy: accuracy);
  }

  static Future<Position?> getLastKnownPosition() async {
    return await Geolocator.getLastKnownPosition();
  }

  static Stream<Position> getPositionStream(
      {LocationAccuracy accuracy = LocationAccuracy.high,
      int distanceFilter = 100}) {
    final LocationSettings locationSettings =
        LocationSettingsConfig.getPlatformLocationSettings();
    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  static Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  static Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  static Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  // (iOS 14+ and Android 만 적용 가능)
  static Future<LocationAccuracyStatus> getLocationAccuracy() async {
    return await Geolocator.getLocationAccuracy();
  }

  static Stream<ServiceStatus> getServiceStatusStream() {
    return Geolocator.getServiceStatusStream();
  }
}

class LocationSettingsConfig {
  static LocationSettings getPlatformLocationSettings() {
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.fitness,
        distanceFilter: 100,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
      );
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
        forceLocationManager: true,
        intervalDuration: const Duration(seconds: 10),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationText: "App is tracking your location in the background.",
          notificationTitle: "Background Location Tracking",
          enableWakeLock: true,
        ),
      );
    } else {
      return const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );
    }
  }
}
