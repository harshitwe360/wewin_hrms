import 'package:geolocator/geolocator.dart';

import '../config/r.dart';

/// Why a location could not be read.
enum LocationIssue {
  /// Location services (GPS) are switched off.
  serviceOff,

  /// The user denied the permission prompt (can be asked again).
  denied,

  /// Permanently denied: only the system Settings can fix it.
  blocked,
}

class LocationException implements Exception {
  const LocationException(this.issue, this.message);

  final LocationIssue issue;
  final String message;

  /// Opens the Settings page that fixes this issue.
  Future<bool> openSettings() => issue == LocationIssue.serviceOff
      ? Geolocator.openLocationSettings()
      : Geolocator.openAppSettings();

  @override
  String toString() => message;
}

/// Device location for attendance punches.
class LocationService {
  LocationService._();

  static final LocationService instance = LocationService._();

  /// Current position, requesting permission if needed.
  /// Throws [LocationException] when services are off or permission is refused.
  Future<Position> currentPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw LocationException(
          LocationIssue.serviceOff, R.strings.msgLocationDisable);
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationException(LocationIssue.denied, R.strings.msgLocationDenied);
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw LocationException(LocationIssue.blocked, R.strings.msgLocationPDenied);
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 20),
      ),
    );
  }
}
