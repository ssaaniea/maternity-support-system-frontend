import 'package:flutter/material.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          "Track",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: Container(
        width: double.infinity,
        height: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 158, 204, 200),
              Color.fromARGB(255, 226, 223, 222),
              Color(0xffeecde6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: Column(
          children: [
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,

                children: [
                  _buildTrackCard(
                    icon: Icons.monitor_weight,
                    label: "Weight",
                    color: Colors.green.shade50,
                  ),
                  _buildTrackCard(
                    icon: Icons.sick,
                    label: "Symptoms",
                    color: Colors.green.shade50,
                  ),
                  _buildTrackCard(
                    icon: Icons.child_care,
                    label: "Kick Count",
                    color: Colors.green.shade50,
                  ),
                  _buildTrackCard(
                    icon: Icons.health_and_safety,
                    label: "Checkup",
                    color: Colors.green.shade50,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------
  //     CARD WIDGET
  // --------------------------
  Widget _buildTrackCard({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 38, color: Colors.black87),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
