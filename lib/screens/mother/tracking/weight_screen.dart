import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:project_frontend/constants.dart';
import 'package:project_frontend/models/tracking_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeightScreen extends StatefulWidget {
  const WeightScreen({super.key});

  @override
  State<WeightScreen> createState() => _WeightScreenState();
}

class _WeightScreenState extends State<WeightScreen> {
  bool _isLoading = true;
  List<WeightLog> _logs = [];

  @override
  void initState() {
    super.initState();
    _fetchWeights();
  }

  Future<void> _fetchWeights() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("jwt_token");

      if (token == null) {
        // Handle not logged in (optional)
        setState(() => _isLoading = false);
        return;
      }

      final url = Uri.parse('$kBaseRoute/mother/me/weight-logs');
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
            .map((e) => WeightLog.fromJson(e))
            .toList();
        setState(() {
          _logs = list;
          _isLoading = false;
        });
      } else {
        // Handle error
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print("Error fetching weights: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addWeight(double weight, String notes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("jwt_token");
      if (token == null) return;

      final url = Uri.parse('$kBaseRoute/mother/me/weight-logs');
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "weight_kg": weight,
          "notes": notes,
          "date": DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        _fetchWeights(); // Refresh list
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Weight logged successfully!")),
          );
        }
      } else {
        print("Failed to add weight: ${response.body}");
      }
    } catch (e) {
      print("Error adding weight: $e");
    }
  }

  void _showAddDialog() {
    final weightController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Log Weight"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Weight (kg)",
                suffixText: "kg",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: "Notes (optional)",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final w = double.tryParse(weightController.text);
              if (w != null) {
                _addWeight(w, notesController.text);
                Navigator.pop(ctx);
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
        title: const Text("Weight Tracker"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        label: const Text("Log Weight"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _logs.isEmpty
              ? const Center(child: Text("No weight logs yet. Start tracking!"))
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
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.teal.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.monitor_weight,
                              color: Colors.teal),
                        ),
                        title: Text(
                          "${log.weight} kg",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${log.date.day}/${log.date.month}/${log.date.year}",
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                            if (log.notes != null && log.notes!.isNotEmpty)
                              Text(
                                log.notes!,
                                style: const TextStyle(fontStyle: FontStyle.italic),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
