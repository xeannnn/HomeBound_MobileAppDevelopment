import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/transit_repository.dart';
import '../../shared/models/stop.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/data_source_badge.dart';
import 'widgets/countdown_card.dart';
import 'widgets/live_map_preview_card.dart';
import 'widgets/stat_tile.dart';
import 'widgets/stop_tile.dart';

/// MODULE: Last Service Tracker (Chung Wei Xean)
/// Loads stops from TransitRepository (live GTFS Static feed from
/// api.data.gov.my, falling back to mock data automatically), then wires
/// the live countdown timer into the widgets in ./widgets/. Edit those
/// files to change how individual pieces look; edit this file to change
/// layout, data loading, or behaviour.
class LastServiceTrackerScreen extends StatefulWidget {
  final VoidCallback? onOpenLiveMap;

  const LastServiceTrackerScreen({super.key, this.onOpenLiveMap});

  @override
  State<LastServiceTrackerScreen> createState() => _LastServiceTrackerScreenState();
}

class _LastServiceTrackerScreenState extends State<LastServiceTrackerScreen> {
  Timer? _timer;
  bool _loading = true;
  List<Stop> _stops = MockData.nearbyStops;
  TransitDataSource _source = TransitDataSource.mock;
  Duration _remaining = Duration.zero;

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
      _remaining = _nearestStop.timeToDeparture;
      _loading = false;
    });
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_remaining.inSeconds > 0) {
          _remaining -= const Duration(seconds: 1);
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // KL Sentral is index 1 in both the mock list and the merged live list —
  // TransitRepository preserves order/position when merging GTFS data in.
  Stop get _nearestStop => _stops.length > 1 ? _stops[1] : _stops.first;

  ServiceUrgency get _urgency {
    if (_remaining.inMinutes <= 5) return ServiceUrgency.critical;
    if (_remaining.inMinutes <= 20) return ServiceUrgency.closingSoon;
    return ServiceUrgency.onTime;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.gold));
    }

    final criticalCount = _stops.where((s) => s.urgency == ServiceUrgency.critical).length;

    return RefreshIndicator(
      color: AppColors.gold,
      backgroundColor: AppColors.surface,
      onRefresh: () async {
        final result = await TransitRepository.instance.getNearbyStops(forceRefresh: true);
        if (!mounted) return;
        setState(() {
          _stops = result.stops;
          _source = result.source;
        });
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Homebound', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.surface,
                child: const Icon(Icons.person_rounded, color: AppColors.gold, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(alignment: Alignment.centerLeft, child: DataSourceBadge(source: _source)),
          const SizedBox(height: 16),
          CountdownCard(stop: _nearestStop, remaining: _remaining, urgency: _urgency),
          const SizedBox(height: 16),
          LiveMapPreviewCard(
            nearbyCount: _stops.length,
            criticalCount: criticalCount,
            onTap: widget.onOpenLiveMap,
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(child: StatTile(label: 'Next Bus', value: '11:52', caption: 'Rapid KL 780')),
              SizedBox(width: 12),
              Expanded(child: StatTile(label: 'Delay Risk', value: '68%', caption: 'AI prediction')),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Nearby Stops', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          ..._stops.map((s) => StopTile(stop: s)),
        ],
      ),
    );
  }
}