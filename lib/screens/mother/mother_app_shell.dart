import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:project_frontend/screens/mother/care/care_screen.dart';
import 'package:project_frontend/screens/mother/explore/explore_screen.dart';
import 'package:project_frontend/screens/mother/home_screen.dart';
import 'package:project_frontend/screens/mother/profile/profile_screen.dart';
import 'package:project_frontend/screens/mother/tracking/tracking_screen.dart';

class MotherAppShell extends StatefulWidget {
  final int initialTabIndex;

  const MotherAppShell({super.key, this.initialTabIndex = 0});

  @override
  State<MotherAppShell> createState() => _MotherAppShellState();

  /// Navigate to a specific tab from anywhere in the app
  static void switchToTab(BuildContext context, int tabIndex) {
    // Find the MotherAppShell in the widget tree
    final state = context.findAncestorStateOfType<_MotherAppShellState>();
    if (state != null) {
      state._switchTab(tabIndex);
    } else {
      // If MotherAppShell is not in the widget tree, navigate to it
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => MotherAppShell(initialTabIndex: tabIndex),
        ),
        (route) => false,
      );
    }
  }
}

class _MotherAppShellState extends State<MotherAppShell> {
  late int _bottomNavIndex;

  final List<Widget> _screens = const [
    HomeScreen(),
    TrackingScreen(),
    ExploreScreen(),
    CareScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _bottomNavIndex = widget.initialTabIndex;
  }

  void _switchTab(int index) {
    setState(() => _bottomNavIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_bottomNavIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Iconsax.home_2,
                  activeIcon: Iconsax.home_25,
                  label: "Home",
                ),
                _buildNavItem(
                  index: 1,
                  icon: Iconsax.chart,
                  activeIcon: Iconsax.chart5,
                  label: "Track",
                ),
                _buildNavItem(
                  index: 2,
                  icon: Iconsax.discover,
                  activeIcon: Iconsax.discover_1,
                  label: "Explore",
                ),
                _buildNavItem(
                  index: 3,
                  icon: Iconsax.heart,
                  activeIcon: Iconsax.heart5,
                  label: "Care",
                ),
                _buildNavItem(
                  index: 4,
                  icon: Iconsax.user,
                  activeIcon: Iconsax.user,
                  label: "Profile",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = _bottomNavIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _bottomNavIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.pink.shade50 : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 24,
              color: isSelected ? Colors.pink : Colors.grey,
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: Colors.pink,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
