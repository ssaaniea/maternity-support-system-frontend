import 'package:flutter/material.dart';
import 'package:project_frontend/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Profile"),
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              // navigate to help or show dialog
            },
          ),
        ],
      ),
      body: Container(
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                // -------- Profile Section ----------
                SizedBox(
                  width: double.infinity,
                  height: 250,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 15,
                    children: [
                      Container(
                        height: 140,
                        width: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color.fromARGB(255, 213, 228, 230),
                        ),
                      ),
                      const Text(
                        "Fathima",
                        style: TextStyle(fontSize: 20),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 193, 222, 220),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          child: Text("fathima@gmail.com"),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // --------- Cards Section ----------
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        profileCard(
                          icon: Icons.person,
                          title: "Personal Information",
                          color: const Color.fromARGB(255, 215, 220, 220),
                          onTap: () {},
                        ),
                        profileCard(
                          icon: Icons.security,
                          title: "Security",
                          color: const Color.fromARGB(255, 215, 220, 220),
                          onTap: () {},
                        ),
                        profileCard(
                          icon: Icons.edit,
                          title: "Edit Profile",
                          onTap: () {},
                          color: const Color.fromARGB(255, 215, 220, 220),
                        ),
                        profileCard(
                          icon: Icons.privacy_tip,
                          title: "Privacy Policy ",
                          color: const Color.fromARGB(255, 215, 220, 220),
                          onTap: () {},
                        ),
                        profileCard(
                          icon: Icons.settings,
                          title: "Settings",
                          color: const Color.fromARGB(255, 215, 220, 220),
                          onTap: () {},
                        ),
                        profileCard(
                          icon: Icons.logout,
                          title: "Logout",
                          color: const Color.fromARGB(255, 215, 220, 220),
                          onTap: () async {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.clear();
                            if (context.mounted) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginScreen(),
                                ),
                                (route) => false,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Reusable Card Widget
  Widget profileCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              Icon(icon, size: 28),
              const SizedBox(width: 15),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
