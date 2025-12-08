import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:project_frontend/constants.dart';
import 'package:project_frontend/models/tracking_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SymptomScreen extends StatefulWidget {
  const SymptomScreen({super.key});

  @override
  State<SymptomScreen> createState() => _SymptomScreenState();
}

class _SymptomScreenState extends State<SymptomScreen> {
  bool _isLoading = true;
  List<SymptomLog> _logs = [];

  final List<String> _allSymptoms = [
    "nausea",
    "fatigue",
    "headache",
    "back_pain",
    "swelling",
    "cramps",
    "mood_swings",
    "insomnia",
    "heartburn",
    "dizziness",
    "constipation",
    "other",
  ];

  final List<String> _moods = [
    "great",
    "good",
    "okay",
    "tired",
    "stressed",
    "sad",
  ];

  @override
  void initState() {
    super.initState();
    _fetchSymptoms();
  }

  Future<void> _fetchSymptoms() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("jwt_token");
      if (token == null) {
        setState(() => _isLoading = false);
        return;
      }

      final url = Uri.parse('$kBaseRoute/mother/me/symptom-logs');
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
            .map((e) => SymptomLog.fromJson(e))
            .toList();
        setState(() {
          _logs = list;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print("Error fetching symptoms: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addSymptomLog(
    List<String> symptoms,
    String mood,
    String notes,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("jwt_token");
      if (token == null) return;

      final url = Uri.parse('$kBaseRoute/mother/me/symptom-logs');
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "symptoms": symptoms,
          "mood": mood,
          "notes": notes,
          "date": DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        _fetchSymptoms();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Symptoms logged successfully!")),
          );
        }
      } else {
        print("Failed to add symptom: ${response.body}");
      }
    } catch (e) {
      print("Error adding symptom: $e");
    }
  }

  void _showAddDialog() {
    List<String> selectedSymptoms = [];
    String selectedMood = _moods[2]; // Default 'okay'
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Log Symptoms"),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "How are you feeling?",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _allSymptoms.map((symptom) {
                        final isSelected = selectedSymptoms.contains(symptom);
                        return FilterChip(
                          label: Text(symptom.replaceAll('_', ' ')),
                          selected: isSelected,
                          onSelected: (bool selected) {
                            setState(() {
                              if (selected) {
                                selectedSymptoms.add(symptom);
                              } else {
                                selectedSymptoms.remove(symptom);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Mood",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    DropdownButton<String>(
                      value: selectedMood,
                      isExpanded: true,
                      items: _moods.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => selectedMood = val);
                      },
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
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  _addSymptomLog(
                    selectedSymptoms,
                    selectedMood,
                    notesController.text,
                  );
                  Navigator.pop(ctx);
                },
                child: const Text("Save"),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Symptom Tracker"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        label: const Text("Log Symptoms"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.purple,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _logs.isEmpty
          ? const Center(child: Text("No symptoms logged yet."))
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
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${log.date.day}/${log.date.month}/${log.date.year}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Chip(
                              label: Text(
                                log.mood?.toUpperCase() ?? "UNKNOWN",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                              backgroundColor: Colors.purple.shade300,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: log.symptoms
                              .map(
                                (s) => Chip(
                                  label: Text(
                                    s.replaceAll('_', ' '),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  backgroundColor: Colors.purple.shade50,
                                  visualDensity: VisualDensity.compact,
                                ),
                              )
                              .toList(),
                        ),
                        if (log.notes != null && log.notes!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            log.notes!,
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
