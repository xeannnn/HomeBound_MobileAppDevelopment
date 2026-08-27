/// A single row from GTFS `stops.txt` — one physical transit stop/station.
class GtfsStop {
  final String stopId;
  final String name;
  final double lat;
  final double lon;

  const GtfsStop({
    required this.stopId,
    required this.name,
    required this.lat,
    required this.lon,
  });
}

/// A single row from GTFS `routes.txt` — one bus/rail line.
class GtfsRoute {
  final String routeId;
  final String shortName;
  final String longName;

  const GtfsRoute({
    required this.routeId,
    required this.shortName,
    required this.longName,
  });
}