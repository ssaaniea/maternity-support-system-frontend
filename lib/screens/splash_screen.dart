import 'package:flutter/material.dart';
import 'package:project_frontend/screens/caregiver/caregiver_app_shell.dart';
import 'package:project_frontend/screens/mother/mother_app_shell.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_frontend/screens/login_screen.dart';

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

    print('role: $role, token: ${token != null ? 'exists' : 'null'}');

    await Future.delayed(
      const Duration(seconds: 1),
    ); // small delay for splash effect

    if (!mounted) return;

    if (token != null && role != null) {
      if (role == "mother") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MotherAppShell()),
        );
      } else if (role == "caregiver") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CaregiverAppShell()),
        );
      } else if (role == "admin") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const Placeholder(),
          ), // TODO: AdminScreen
        );
      } else if (role == "doctor") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const Placeholder(),
          ), // TODO: DoctorScreen
        );
      } else {
        // Unknown role, go to login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
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
