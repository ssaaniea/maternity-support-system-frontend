import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:project_frontend/constants.dart';
import 'package:project_frontend/screens/login_screen.dart';
import 'package:project_frontend/screens/mother/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            spacing: 18,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  spacing: 10,
                  children: [
                    Text(
                      "Let's Get Started",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text('Create new account'),
                  ],
                ),
              ),

              Text('Enter a email'),

              TextField(
                decoration: InputDecoration(
                  hintText: 'email',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),

                  fillColor: Colors.white,
                  filled: true,
                ),
              ),

              Text('Enter a password'),
              TextField(
                decoration: InputDecoration(
                  hintText: 'password',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  fillColor: Colors.white,
                  filled: true,
                ),
                onChanged: (value) {
                  print('password is $value');
                },
              ),
              Text('Select your role'),
              DropdownMenu<String>(
                width: double.infinity,
                requestFocusOnTap: true,
                hintText: 'Select role',
                inputDecorationTheme: InputDecorationTheme(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                menuStyle: MenuStyle(
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        16,
                      ), // set border radius here
                    ),
                  ),
                ),
                dropdownMenuEntries: const [
                  DropdownMenuEntry(value: "Doctor", label: "Doctor"),
                  DropdownMenuEntry(value: "Caregiver", label: "Caregiver"),
                  DropdownMenuEntry(value: "Mother", label: "Mother"),
                ],
              ),

              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text(
                      'Sign up',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
              ),
              Center(
                child: InkWell(
                  onTap: () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => const LoginScreen(),
                      ),
                    ),
                  },
                  child: Text(
                    "Already have an account? Login",
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onSignUpPressed(
    String email,
    String password,
    String role,
  ) async {
    const signupRoute = '$kBaseRoute/auth/signup';

    var body = jsonEncode({"email": email, "password": password, "role": role});

    try {
      final response = await post(
        Uri.parse(signupRoute),
        headers: {"Accept": "*/*", "Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        final parsedBody = jsonDecode(response.body);

        print(parsedBody);

        final token = parsedBody['token']; // from backend
        final role = parsedBody['data']["role"];

        print('role, ${role}, token: ${token}');

        // Save token locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("jwt_token", token);
        await prefs.setString("user_role", role);

        // Navigate by role
        if (role == 'mother') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute<void>(builder: (context) => const HomeScreen()),
            (r) => false,
          );
        } else if (role == 'admin') {
          // TODO: replace with your admin screen
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute<void>(builder: (context) => const Placeholder()),
            (r) => false,
          );
        } else if (role == 'doctor') {
          // TODO: replace with your doctor screen
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute<void>(builder: (context) => const Placeholder()),
            (r) => false,
          );
        } else if (role == 'caregiver') {
          // TODO: replace with your caregiver screen
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute<void>(builder: (context) => const Placeholder()),
            (r) => false,
          );
        }
      } else {
        print('error');
        final error = jsonDecode(response.body);
        _showError(error['message'] ?? "Login failed");
      }
    } catch (e) {
      _showError("Something went wrong: $e");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
