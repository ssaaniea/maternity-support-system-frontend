import 'package:flutter/material.dart';
import 'package:project_frontend/screens/login_screen.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

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
                  hintText: ('email'),
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
                  hintText: ('password'),
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  fillColor: Colors.white,
                  filled: true,
                ),
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
}
