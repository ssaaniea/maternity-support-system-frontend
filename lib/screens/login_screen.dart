import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:project_frontend/constants.dart';
import 'package:project_frontend/screens/mother/home_screen.dart';
import 'package:project_frontend/screens/mother/mother_app_shell.dart';
import 'package:project_frontend/screens/signup_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 249, 246, 249),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                spacing: 8,
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
                        Text('Login to your account'),
                      ],
                    ),
                  ),

                  SizedBox(height: 100),

                  Text('Enter your email'),

                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: ('email'),
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),

                      fillColor: Colors.white,
                      filled: true,
                    ),
                    onChanged: (value) {
                      print('email is $value');
                    },
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Text('Enter your password'),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      hintText: ('password'),
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),

                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          _onLoginPressed(
                            emailController.text,
                            passwordController.text,
                          );
                        },
                        child: Text(
                          'Sign in',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
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
                            builder: (context) => const SignupScreen(),
                          ),
                        ),
                      },
                      child: Text(
                        "Dont have an account? Signup",
                        style: TextStyle(decoration: TextDecoration.underline),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onLoginPressed(String email, String password) async {
    const loginRoute = '$kBaseRoute/auth/signin';

    var body = jsonEncode({
      "email": email,
      "password": password,
    });

    try {
      final response = await post(
        Uri.parse(loginRoute),
        headers: {"Accept": "*/*", "Content-Type": "application/json"},
        body: body,
      );
      print(response);
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
            MaterialPageRoute<void>(
              builder: (context) => const MotherAppShell(),
            ),
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
