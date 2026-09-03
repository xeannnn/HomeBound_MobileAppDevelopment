import 'package:latlong2/latlong.dart';
import '../shared/models/stop.dart';
import 'gtfs_models.dart';
import 'gtfs_service.dart';

/// Where the currently-displayed stop data came from. Surfaced in the UI
/// (small badge) so it's honest about whether a session is live or offline.
enum TransitDataSource { live, cached, mock }

class TransitLookupResult {
  final List<Stop> stops;
  final TransitDataSource source;
  const TransitLookupResult(this.stops, this.source);
}

/// Single source of truth for "what stops should the app show right now".
///
/// Tries the real GTFS Static API (api.data.gov.my, no key required) first.
/// On success, real station names/coordinates from the feed are merged
/// into our known stop list by fuzzy name match. Departure countdowns and
/// urgency stay simulated (see Stop docs) — this call only fetches
/// schedules/geography, not which service is realistically "last" tonight.
///
/// On any failure (offline, feed down, rate-limited, unexpected format),
/// this silently falls back to MockData so the app never breaks a demo.
/// Results are cached in-memory for the life of the app so we don't
/// re-download the multi-MB GTFS ZIP on every screen visit.
class TransitRepository {
  TransitRepository._();
  static final TransitRepository instance = TransitRepository._();

  List<Stop>? _cachedStops;
  TransitDataSource _lastSource = TransitDataSource.mock;

  TransitDataSource get lastSource => _lastSource;

  Future<TransitLookupResult> getNearbyStops(
      {bool forceRefresh = false}) async {
    if (_cachedStops != null && !forceRefresh) {
      return TransitLookupResult(_cachedStops!, TransitDataSource.cached);
    }

    try {
      final gtfsStops = await GtfsService.fetchStops(category: 'rapid-rail-kl');
      final merged = _mergeWithMock(gtfsStops);
      _cachedStops = merged;
      _lastSource = TransitDataSource.live;
      return TransitLookupResult(merged, TransitDataSource.live);
    } catch (_) {
      // Network unavailable, feed changed shape, rate limited, etc.
      // Fall back to mock data rather than showing an error screen — last-
      // service info during a genuine outage is exactly when this app
      // most needs to still work.
      _cachedStops = MockData.nearbyStops;
      _lastSource = TransitDataSource.mock;
      return TransitLookupResult(MockData.nearbyStops, TransitDataSource.mock);
    }
  }

  /// Orders the available stop list by walking distance from a device location.
  /// The distance is calculated locally, so this still works with cached data.
  List<Stop> sortByDistance(List<Stop> stops, LatLng userLocation) {
    const distance = Distance();
    final ordered = [...stops];
    ordered.sort((a, b) => distance
        .as(LengthUnit.Meter, userLocation, a.position)
        .compareTo(distance.as(LengthUnit.Meter, userLocation, b.position)));
    return ordered;
  }

  /// Replaces each mock stop's coordinates/id with the real GTFS entry
  /// whose name contains ours (case-insensitive), when one exists. Keeps
  /// our simulated platform/countdown/urgency either way.
  List<Stop> _mergeWithMock(List<GtfsStop> gtfsStops) {
    return MockData.nearbyStops.map((mock) {
      final target = _stripSuffix(mock.name).toLowerCase();
      GtfsStop? match;
      for (final g in gtfsStops) {
        if (g.name.toLowerCase().contains(target)) {
          match = g;
          break;
        }
      }
      if (match == null) return mock;
      return mock.copyWith(
        position: LatLng(match.lat, match.lon),
        gtfsStopId: match.stopId,
      );
    }).toList();
  }

  String _stripSuffix(String name) {
    // "Pasar Seni LRT" -> "Pasar Seni" so it matches GTFS naming variants.
    return name
        .replaceAll(RegExp(r'\s+(LRT|MRT|Station)$', caseSensitive: false), '')
        .trim();
  }
}
