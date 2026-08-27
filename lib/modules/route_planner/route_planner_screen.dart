import 'package:flutter/material.dart';
import '../../shared/models/route_model.dart';
import 'widgets/location_field.dart';
import 'widgets/route_card.dart';


/// Screen wires state (origin/destination controllers, search trigger)
/// into the widgets in modules/route_planner/widgets/.
class RoutePlannerScreen extends StatefulWidget {
  const RoutePlannerScreen({super.key});

  @override
  State<RoutePlannerScreen> createState() => _RoutePlannerScreenState();
}

class _RoutePlannerScreenState extends State<RoutePlannerScreen> {
  final _originController = TextEditingController(text: MockRoutes.origin);
  final _destinationController = TextEditingController(text: MockRoutes.destination);
  bool _searched = true;

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        const Text('Route Planner', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        LocationField(icon: Icons.trip_origin, hint: 'Origin stop name', controller: _originController),
        const SizedBox(height: 10),
        LocationField(icon: Icons.location_on_rounded, hint: 'Destination stop name', controller: _destinationController),
        const SizedBox(height: 14),
        ElevatedButton(
          onPressed: () => setState(() => _searched = true),
          child: const Text('Find Routes'),
        ),
        const SizedBox(height: 22),
        if (_searched) ...[
          const Text('3 Routes · Last Service Window', style: TextStyle(fontSize: 13, color: Color(0xFF9BA0C2))),
          const SizedBox(height: 12),
          ...MockRoutes.options.map((r) => RouteCard(route: r)),
        ],
      ],
    );
  }
}