import 'package:flutter/material.dart';
import '../shared/theme/app_theme.dart';
import '../shared/widgets/bottom_nav.dart';
import '../modules/last_service_tracker/last_service_tracker_screen.dart';
import '../modules/live_map/live_map_screen.dart';
import '../modules/route_planner/route_planner_screen.dart';
import 'placeholder_module_screen.dart';

/// Top-level shell: Home Dashboard (hub) -> Last Service Tracker / Live Map /
/// Route Planner (Chung Wei Xean's modules) plus stubs for AI Delay
/// Prediction and SOS Panic Button (Kaiser's modules, built separately).
class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  int _index = 0;

  void _goToTab(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final screens = [
      LastServiceTrackerScreen(onOpenLiveMap: () => _goToTab(1)),
      const LiveMapScreen(),
      const RoutePlannerScreen(),
      const PlaceholderModuleScreen(
        title: 'AI Delay Prediction',
        owner: 'Kaiser Tan King Sheng',
        icon: Icons.auto_graph_rounded,
      ),
      const PlaceholderModuleScreen(
        title: 'SOS Panic Button',
        owner: 'Kaiser Tan King Sheng',
        icon: Icons.sos_rounded,
        accent: AppColors.critical,
      ),
    ];

    return Scaffold(
      body: SafeArea(child: IndexedStack(index: _index, children: screens)),
      bottomNavigationBar: HomeboundBottomNav(currentIndex: _index, onTap: _goToTab),
    );
  }
}