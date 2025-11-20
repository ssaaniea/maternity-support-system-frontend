import 'package:flutter/material.dart';
import 'package:project_frontend/screens/mother/mother_app_shell.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_frontend/screens/login_screen.dart';
import 'package:project_frontend/screens/mother/home_screen.dart';
// import your AdminScreen, DoctorScreen, CaregiverScreen

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("jwt_token");
    final role = prefs.getString("user_role");

    print('role : ${token}');

    await Future.delayed(
      const Duration(seconds: 1),
    ); // small delay for splash effect

    if (token != null && role != null) {
      if (role == "mother") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MotherAppShell()),
        );
      } else if (role == "admin") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Placeholder()), // AdminScreen
        );
      } else if (role == "doctor") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const Placeholder(),
          ), // DoctorScreen
        );
      } else if (role == "caregiver") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const Placeholder(),
          ), // CaregiverScreen
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
