import 'package:flutter/material.dart';
import '../../../shared/models/stop.dart';
import '../../../shared/theme/app_theme.dart';

/// Compact row used in the scrollable "Nearby Stops" panel beneath the
/// live map. Deliberately simpler than the dashboard's StopTile — no
/// second status label, since screen space is tighter here.
class StopListTile extends StatelessWidget {
  final Stop stop;
  const StopListTile({super.key, required this.stop});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: stop.urgency.color, shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stop.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(stop.platform, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text(stop.formattedCountdown, style: TextStyle(color: stop.urgency.color, fontWeight: FontWeight.w700, fontSize: 13)),
        ],
      ),
    );
  }
}