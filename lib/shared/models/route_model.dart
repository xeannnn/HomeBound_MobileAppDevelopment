import '../theme/app_theme.dart';

/// A single candidate route/departure returned by the planner.
class RouteOption {
  final String departureTime;
  final String mode; // e.g. "LRT · MRT"
  final String etaSummary; // e.g. "Arrives 12:04 AM · 22 min"
  final double confidence; // 0.0 - 1.0, feeds AI Delay Prediction module
  final ServiceUrgency status;

  const RouteOption({
    required this.departureTime,
    required this.mode,
    required this.etaSummary,
    required this.confidence,
    required this.status,
  });
}

class MockRoutes {
  static const String origin = 'KL Sentral LRT';
  static const String destination = 'Kelana Jaya Station';

  static const List<RouteOption> options = [
    RouteOption(
      departureTime: '11:42 PM',
      mode: 'LRT · MRT',
      etaSummary: 'Arrives 12:04 AM · 22 min',
      confidence: 0.94,
      status: ServiceUrgency.onTime,
    ),
    RouteOption(
      departureTime: '11:51 PM',
      mode: 'BUS · LRT',
      etaSummary: 'Arrives 12:09 AM · 18 min',
      confidence: 0.81,
      status: ServiceUrgency.closingSoon,
    ),
    RouteOption(
      departureTime: '12:03 AM',
      mode: 'BUS · LRT',
      etaSummary: 'Arrives 12:38 AM · 35 min',
      confidence: 0.35,
      status: ServiceUrgency.critical,
    ),
  ];
}