import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:project_frontend/providers/caregiver_provider.dart';
import 'package:project_frontend/screens/caregiver/bookings/caregiver_bookings_screen.dart';
import 'package:project_frontend/screens/caregiver/home/caregiver_home_screen.dart';
import 'package:project_frontend/screens/caregiver/profile/caregiver_profile_screen.dart';
import 'package:provider/provider.dart';

class CaregiverAppShell extends StatefulWidget {
  final int initialTabIndex;

  const CaregiverAppShell({super.key, this.initialTabIndex = 0});

  @override
  State<CaregiverAppShell> createState() => _CaregiverAppShellState();

  /// Navigate to a specific tab from anywhere in the app
  static void switchToTab(BuildContext context, int tabIndex) {
    final state = context.findAncestorStateOfType<_CaregiverAppShellState>();
    if (state != null) {
      state._switchTab(tabIndex);
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => CaregiverAppShell(initialTabIndex: tabIndex),
        ),
        (route) => false,
      );
    }
  }
}

class _CaregiverAppShellState extends State<CaregiverAppShell> {
  late int _bottomNavIndex;
  bool _isCheckingProfile = true;

  final List<Widget> _screens = const [
    CaregiverHomeScreen(),
    CaregiverBookingsScreen(),
    CaregiverProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _bottomNavIndex = widget.initialTabIndex;
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = context.read<CaregiverProvider>();
    await provider.loadProfile();

    if (!mounted) return;

    // If unauthorized response occurred, ApiService already handles redirect to login
    if (provider.wasUnauthorized) {
      return;
    }

    // Profile loaded (or doesn't exist) - proceed to home
    setState(() => _isCheckingProfile = false);
    provider.loadBookings();
  }

  void _switchTab(int index) {
    setState(() => _bottomNavIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingProfile) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  icon: Iconsax.calendar,
                  activeIcon: Iconsax.calendar_1,
                  label: "Bookings",
                ),
                _buildNavItem(
                  index: 2,
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
          horizontal: isSelected ? 20 : 16,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal.shade50 : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 24,
              color: isSelected ? Colors.teal : Colors.grey,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: Colors.teal,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
