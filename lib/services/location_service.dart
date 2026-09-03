import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

enum LocationStatus { available, disabled, denied, deniedForever, unavailable }

class LocationResult {
  final LocationStatus status;
  final LatLng? position;

  const LocationResult(this.status, [this.position]);
}

/// Requests location only after an explicit user action, so the app never
/// surprises people with a permission dialog on launch.
class LocationService {
  LocationService._();
  static final instance = LocationService._();

  Future<LocationResult> requestCurrentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return const LocationResult(LocationStatus.disabled);
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      return const LocationResult(LocationStatus.denied);
    }
    if (permission == LocationPermission.deniedForever) {
      return const LocationResult(LocationStatus.deniedForever);
    }
    try {
      final position = await Geolocator.getCurrentPosition();
      return LocationResult(LocationStatus.available,
          LatLng(position.latitude, position.longitude));
    } catch (_) {
      return const LocationResult(LocationStatus.unavailable);
    }
  }
}
