import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../theme/app_theme.dart';

/// A transit stop/station shown on the Last Service Tracker and Live Map.
///
/// `position`, `name` and `gtfsStopId` can come from the live GTFS Static
/// feed (see TransitRepository); `timeToDeparture` and `urgency` are
/// simulated — the GTFS Static feed only has schedules, not which trip is
/// realistically "last" tonight, so that part stays mocked until the AI
/// Delay Prediction module (Kaiser) or a full stop_times.txt pass covers it.
class Stop {
  final String name;
  final String platform;
  final LatLng position;
  final Duration timeToDeparture;
  final ServiceUrgency urgency;
  final String? gtfsStopId;

  const Stop({
    required this.name,
    required this.platform,
    required this.position,
    required this.timeToDeparture,
    required this.urgency,
    this.gtfsStopId,
  });

  Stop copyWith({
    String? name,
    String? platform,
    LatLng? position,
    Duration? timeToDeparture,
    ServiceUrgency? urgency,
    String? gtfsStopId,
  }) {
    return Stop(
      name: name ?? this.name,
      platform: platform ?? this.platform,
      position: position ?? this.position,
      timeToDeparture: timeToDeparture ?? this.timeToDeparture,
      urgency: urgency ?? this.urgency,
      gtfsStopId: gtfsStopId ?? this.gtfsStopId,
    );
  }

  String get formattedCountdown {
    final m = timeToDeparture.inMinutes.remainder(60);
    final s = timeToDeparture.inSeconds.remainder(60);
    return '${m}m ${s.toString().padLeft(2, '0')}s';
  }
}

/// Mock dataset standing in for the real-time feed described in the
/// proposal (RapidKL disruption + last-service data). Swap this out for
/// an actual API/service layer later.
class MockData {
  static final List<Stop> nearbyStops = [
    Stop(
      name: 'Pasar Seni LRT',
      platform: 'Platform 2 · Kelana Jaya Line',
      position: const LatLng(3.1424, 101.6959),
      timeToDeparture: const Duration(minutes: 6, seconds: 11),
      urgency: ServiceUrgency.critical,
    ),
    Stop(
      name: 'KL Sentral',
      platform: 'Platform 1 · KTM Komuter',
      position: const LatLng(3.1341, 101.6866),
      timeToDeparture: const Duration(minutes: 18, seconds: 42),
      urgency: ServiceUrgency.closingSoon,
    ),
    Stop(
      name: 'Masjid Jamek',
      platform: 'Platform 3 · Ampang Line',
      position: const LatLng(3.1488, 101.6956),
      timeToDeparture: const Duration(minutes: 34),
      urgency: ServiceUrgency.onTime,
    ),
  ];

  static const String lastTrainTonight = '11:58 PM';
}