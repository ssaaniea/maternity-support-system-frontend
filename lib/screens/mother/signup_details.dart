import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:project_frontend/constants.dart';
import 'package:project_frontend/screens/mother/mother_app_shell.dart';

class SignupDetails extends StatefulWidget {
  const SignupDetails({super.key});

  @override
  State<SignupDetails> createState() => _SignupDetailsState();
}

class _SignupDetailsState extends State<SignupDetails> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _adresscontroller = TextEditingController();
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();

  bool _isPregnant = false;

  DateTime _dueDate = DateTime.now();

  DateTime _lastPeriodDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Your Full Details'),
        backgroundColor: Colors.pink.shade300,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Email
                _buildTextField(
                  controller: _fullNameController,
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  icon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password
                _buildTextField(
                  controller: _ageController,
                  label: 'age',
                  hint: 'Enter your age',
                  icon: Icons.calendar_today_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your age';
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Confirm Password
                _buildTextField(
                  controller: _phoneNumberController,
                  label: 'phone number',
                  hint: 'Enter your phone number',
                  icon: Icons.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                CheckboxListTile(
                  value: _isPregnant,
                  title: const Text('Are you pregnant?'),
                  onChanged: (value) {
                    setState(() {
                      _isPregnant = !_isPregnant;
                    });
                  },
                ),
                if (_isPregnant) ...[
                  ListTile(
                    leading: Icon(Icons.calendar_month),
                    title: Text(
                      "Expected due date : ${_dueDate.day}/${_dueDate.month}/${_dueDate.year}",
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _dueDate,
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                      );

                      if (date == null) return;

                      setState(() {
                        _dueDate = date;
                      });
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.calendar_month),
                    title: Text(
                      "Last period date : ${_lastPeriodDate.day}/${_lastPeriodDate.month}/${_lastPeriodDate.year}",
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _lastPeriodDate,
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now().add(Duration(days: 1)),
                      );

                      if (date == null) return;

                      setState(() {
                        _lastPeriodDate = date;
                      });
                    },
                  ),
                ],
                const SizedBox(height: 24),
                _buildTextField(
                  controller: _adresscontroller,
                  keyboardType: TextInputType.multiline,
                  minLines: 5,
                  label: 'adress',
                  hint: 'enter your detailed address',
                  icon: Icons.location_city_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Signup Button
                _buildButton(
                  onPressed: _isLoading ? null : _onSubmitPressed,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Submit',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    int? minLines,
    int? maxLines,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      minLines: minLines,
      maxLines: maxLines,
      decoration: InputDecoration(
        // labelText: label,
        hintText: hint,
        prefix: SizedBox(
          height: 28,
          width: 28,
          child: Center(child: Icon(icon)),
        ),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.pink, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: validator,
    );
  }

  Widget _buildButton({
    required VoidCallback? onPressed,
    required Widget child,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
      child: child,
    );
  }

  Future<void> _onSubmitPressed() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      Map<String, dynamic> body = {
        "name": _fullNameController.text.trim(),
        "phone_no": _phoneNumberController.text.trim(),
        "age": _ageController.text.trim(),
        "status": _isPregnant ? "pregnant" : "not_pregnant",
        "expected_delivery_date": _isPregnant
            ? _dueDate.toIso8601String()
            : null,
        "last_period_date": _isPregnant
            ? _lastPeriodDate.toIso8601String()
            : null,
        "address": _adresscontroller.text.trim(),
      };

      final response = await http.post(
        Uri.parse('$kBaseRoute/mother/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 201) {
        _showSnackBar(data['message'], Colors.green);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(
            builder: (context) => const MotherAppShell(),
          ),
          (Route<dynamic> route) => false,
        );
      } else {
        _showSnackBar(data['message'] ?? 'Signup failed', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Network error: ${e.toString()}', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    log(message);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
