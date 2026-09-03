import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HomeboundBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const HomeboundBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    _NavItem('Home', Icons.home_rounded),
    _NavItem('Map', Icons.map_rounded),
    _NavItem('Plan', Icons.alt_route_rounded),
    _NavItem('Predict', Icons.auto_graph_rounded),
    _NavItem('SOS', Icons.sos_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.navy,
        border: Border(top: BorderSide(color: AppColors.divider, width: 0.6)),
      ),
      padding: EdgeInsets.symmetric(
        vertical: isLandscape ? 10 : 8,
        horizontal: isLandscape ? 6 : 0,
      ),
      child: SafeArea(
        top: false,
        child: isLandscape
            ? Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _buildItems(vertical: true),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _buildItems(),
              ),
      ),
    );
  }

  List<Widget> _buildItems({bool vertical = false}) {
    return List.generate(_items.length, (i) {
      final item = _items[i];
      final selected = i == currentIndex;
      final isSos = item.label == 'SOS';
      final color = isSos
          ? AppColors.critical
          : (selected ? AppColors.gold : AppColors.textSecondary);
      return InkWell(
        onTap: () => onTap(i),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: vertical ? 8 : 10,
            vertical: vertical ? 5 : 4,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(item.icon, color: color, size: 22),
              const SizedBox(height: 2),
              Text(
                item.label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  const _NavItem(this.label, this.icon);
}
