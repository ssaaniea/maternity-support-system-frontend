import 'package:flutter/material.dart';
import 'package:project_frontend/screens/signup_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 228, 227, 227),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                decoration: InputDecoration(
                  hintText: ('email'),
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
              Text('Enter your password'),
              TextField(
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
                    onPressed: () {},
                    child: const Text(
                      'Sign in',
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
    );
  }
}
