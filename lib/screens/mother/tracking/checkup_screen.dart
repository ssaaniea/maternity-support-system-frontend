import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:project_frontend/constants.dart';
import 'package:project_frontend/models/tracking_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckupScreen extends StatefulWidget {
  const CheckupScreen({super.key});

  @override
  State<CheckupScreen> createState() => _CheckupScreenState();
}

class _CheckupScreenState extends State<CheckupScreen> {
  bool _isLoading = true;
  List<CheckupLog> _logs = [];

  @override
  void initState() {
    super.initState();
    _fetchCheckups();
  }

  Future<void> _fetchCheckups() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("jwt_token");
      if (token == null) {
        setState(() => _isLoading = false);
        return;
      }

      final url = Uri.parse('$kBaseRoute/mother/me/checkups');
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = (data['data'] as List)
            .map((e) => CheckupLog.fromJson(e))
            .toList();
        setState(() {
          _logs = list;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print("Error fetching checkups: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addCheckup({
    required String doctorName,
    required String hospitalName,
    required double weight,
    required String bp,
    required int heartRate,
    required String notes,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("jwt_token");
      if (token == null) return;

      final url = Uri.parse('$kBaseRoute/mother/me/checkups');
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "date": DateTime.now().toIso8601String(),
          "doctor_name": doctorName,
          "hospital_name": hospitalName,
          "weight_kg": weight,
          "blood_pressure": bp,
          "baby_heart_rate": heartRate,
          "notes": notes,
        }),
      );

      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Checkup logged successfully!")),
          );
        }
        _fetchCheckups();
      } else {
        print("Failed to add checkup: ${response.body}");
      }
    } catch (e) {
      print("Error adding checkup: $e");
    }
  }

  void _showAddDialog() {
    final doctorController = TextEditingController();
    final hospitalController = TextEditingController();
    final weightController = TextEditingController();
    final bpController = TextEditingController();
    final heartRateController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Log Checkup"),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: doctorController,
                  decoration: const InputDecoration(labelText: "Doctor Name"),
                ),
                TextField(
                  controller: hospitalController,
                  decoration: const InputDecoration(labelText: "Hospital Name"),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: weightController,
                        decoration: const InputDecoration(
                          labelText: "Weight (kg)",
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: bpController,
                        decoration: const InputDecoration(
                          labelText: "BP (e.g. 120/80)",
                        ),
                      ),
                    ),
                  ],
                ),
                TextField(
                  controller: heartRateController,
                  decoration: const InputDecoration(
                    labelText: "Baby Heart Rate (bpm)",
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: "Notes"),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final weight = double.tryParse(weightController.text);
              final hr = int.tryParse(heartRateController.text);

              if (weight != null && hr != null) {
                _addCheckup(
                  doctorName: doctorController.text,
                  hospitalName: hospitalController.text,
                  weight: weight,
                  bp: bpController.text,
                  heartRate: hr,
                  notes: notesController.text,
                );
                Navigator.pop(ctx);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Please enter valid numbers for Weight and Heart Rate",
                    ),
                  ),
                );
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkups"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        label: const Text("Log Checkup"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _logs.isEmpty
          ? const Center(child: Text("No checkups logged yet."))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _logs.length,
              itemBuilder: (context, index) {
                final log = _logs[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ExpansionTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.medical_services,
                        color: Colors.green,
                      ),
                    ),
                    title: Text("Dr. ${log.doctorName}"),
                    subtitle: Text(
                      "${log.date.day}/${log.date.month}/${log.date.year} • ${log.hospitalName}",
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildInfoItem(
                                  Icons.monitor_weight,
                                  "${log.weight} kg",
                                  "Weight",
                                ),
                                _buildInfoItem(
                                  Icons.favorite,
                                  "${log.babyHeartRate} bpm",
                                  "Small Heart",
                                ),
                                _buildInfoItem(
                                  Icons.water_drop,
                                  log.bloodPressure ?? "N/A",
                                  "BP",
                                ),
                              ],
                            ),
                            if (log.notes != null && log.notes!.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Text(
                                "Notes: ${log.notes}",
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildInfoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}
