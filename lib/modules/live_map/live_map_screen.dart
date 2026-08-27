import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import '../../services/transit_repository.dart';
import '../../shared/models/stop.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/data_source_badge.dart';
import 'widgets/stop_list_tile.dart';
import 'widgets/stop_pin.dart';

/// Interactive map (flutter_map + OpenStreetMap, no API key needed) with
/// colour-coded stop pins. Stop coordinates come from TransitRepository —
/// real GTFS Static positions from api.data.gov.my when available, mock
/// coordinates otherwise — so this always matches the Last Service Tracker.
class LiveMapScreen extends StatefulWidget {
  const LiveMapScreen({super.key});

  @override
  State<LiveMapScreen> createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends State<LiveMapScreen> {
  bool _loading = true;
  List<Stop> _stops = MockData.nearbyStops;
  TransitDataSource _source = TransitDataSource.mock;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await TransitRepository.instance.getNearbyStops();
    if (!mounted) return;
    setState(() {
      _stops = result.stops;
      _source = result.source;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.gold));
    }

    final center = _stops.length > 1 ? _stops[1].position : _stops.first.position;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.circle, color: AppColors.success, size: 10),
                  SizedBox(width: 6),
                  Text('Live tracking active', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
              DataSourceBadge(source: _source),
            ],
          ),
        ),
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: FlutterMap(
                options: MapOptions(initialCenter: center, initialZoom: 14),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.homebound.app',
                  ),
                  MarkerLayer(
                    markers: _stops
                        .map((stop) => Marker(
                      point: stop.position,
                      width: 40,
                      height: 40,
                      child: StopPin(stop: stop),
                    ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('Nearby Stops', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          flex: 3,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            children: _stops.map((stop) => StopListTile(stop: stop)).toList(),
          ),
        ),
      ],
    );
  }
}