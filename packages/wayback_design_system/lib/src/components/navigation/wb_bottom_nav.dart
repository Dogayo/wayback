import 'package:flutter/material.dart';

import 'package:wayback_design_system/src/theme/app_theme_extensions.dart';

class WbBottomNavItem {
  const WbBottomNavItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

class WbBottomNav extends StatelessWidget {
  const WbBottomNav({
    required this.items,
    required this.index,
    required this.onChanged,
    super.key,
  });
  final List<WbBottomNavItem> items;
  final int index;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) => NavigationBar(
    height: 64,
    selectedIndex: index,
    onDestinationSelected: onChanged,
    backgroundColor: context.wbColors.surfaceElevated,
    indicatorColor: context.wbColors.positiveBg,
    destinations: [
      for (final item in items)
        NavigationDestination(icon: Icon(item.icon), label: item.label),
    ],
  );
}
