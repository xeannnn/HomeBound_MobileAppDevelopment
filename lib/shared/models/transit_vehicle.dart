import 'package:latlong2/latlong.dart';

/// A live vehicle position from a GTFS-Realtime feed.
class TransitVehicle {
  final String id;
  final String routeLabel;
  final LatLng position;
  final DateTime updatedAt;

  const TransitVehicle({
    required this.id,
    required this.routeLabel,
    required this.position,
    required this.updatedAt,
  });
}
