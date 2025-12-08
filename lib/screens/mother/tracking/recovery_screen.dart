import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:project_frontend/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecoveryScreen extends StatefulWidget {
  const RecoveryScreen({super.key});

  @override
  State<RecoveryScreen> createState() => _RecoveryScreenState();
}

class _RecoveryScreenState extends State<RecoveryScreen> {
  List<dynamic> _recoveryLogs = [];
  bool _isLoading = true;

  // Form state
  int _painLevel = 3;
  String _bleeding = "light";
  String _mood = "okay";
  int _sleepHours = 6;
  String _breastfeedingIssues = "";
  String _notes = "";

  final List<String> _bleedingOptions = ["heavy", "moderate", "light", "spotting", "none"];
  final List<String> _moodOptions = ["great", "good", "okay", "tired", "overwhelmed", "sad", "anxious"];

  @override
  void initState() {
    super.initState();
    _fetchRecoveryLogs();
  }

  Future<void> _fetchRecoveryLogs() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("jwt_token");
      if (token == null) return;

      final response = await http.get(
        Uri.parse('$kBaseRoute/mother/me/recovery-logs'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _recoveryLogs = data['data'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print("Error fetching recovery logs: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addRecoveryLog() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("jwt_token");
      if (token == null) return;

      final response = await http.post(
        Uri.parse('$kBaseRoute/mother/me/recovery-logs'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "date": DateTime.now().toIso8601String(),
          "pain_level": _painLevel,
          "bleeding": _bleeding,
          "mood": _mood,
          "sleep_hours": _sleepHours,
          "breastfeeding_issues": _breastfeedingIssues,
          "notes": _notes,
        }),
      );

      if (response.statusCode == 201) {
        Navigator.pop(context);
        _fetchRecoveryLogs();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Recovery log added!"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? "Failed to add log"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  void _showAddLogDialog() {
    // Reset form values
    _painLevel = 3;
    _bleeding = "light";
    _mood = "okay";
    _sleepHours = 6;
    _breastfeedingIssues = "";
    _notes = "";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Log Your Recovery",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pain Level
                      const Text(
                        "Pain Level",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text("1"),
                          Expanded(
                            child: Slider(
                              value: _painLevel.toDouble(),
                              min: 1,
                              max: 10,
                              divisions: 9,
                              label: "$_painLevel",
                              activeColor: Colors.red,
                              onChanged: (v) => setModalState(() => _painLevel = v.round()),
                            ),
                          ),
                          const Text("10"),
                        ],
                      ),
                      Center(
                        child: Text(
                          _getPainEmoji(_painLevel),
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Bleeding
                      const Text(
                        "Bleeding",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _bleedingOptions.map((option) {
                          final isSelected = _bleeding == option;
                          return ChoiceChip(
                            label: Text(option.substring(0, 1).toUpperCase() + option.substring(1)),
                            selected: isSelected,
                            selectedColor: Colors.red.shade100,
                            onSelected: (_) => setModalState(() => _bleeding = option),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Mood
                      const Text(
                        "Mood",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _moodOptions.map((option) {
                          final isSelected = _mood == option;
                          return ChoiceChip(
                            label: Text("${_getMoodEmoji(option)} ${option.substring(0, 1).toUpperCase() + option.substring(1)}"),
                            selected: isSelected,
                            selectedColor: Colors.purple.shade100,
                            onSelected: (_) => setModalState(() => _mood = option),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Sleep Hours
                      const Text(
                        "Hours of Sleep",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text("0h"),
                          Expanded(
                            child: Slider(
                              value: _sleepHours.toDouble(),
                              min: 0,
                              max: 12,
                              divisions: 12,
                              label: "${_sleepHours}h",
                              activeColor: Colors.blue,
                              onChanged: (v) => setModalState(() => _sleepHours = v.round()),
                            ),
                          ),
                          const Text("12h"),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Breastfeeding Issues
                      TextField(
                        decoration: InputDecoration(
                          labelText: "Breastfeeding Issues (optional)",
                          hintText: "e.g., sore nipples, low supply",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (v) => _breastfeedingIssues = v,
                      ),
                      const SizedBox(height: 16),

                      // Notes
                      TextField(
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: "Notes (optional)",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (v) => _notes = v,
                      ),
                      const SizedBox(height: 24),

                      // Submit
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _addRecoveryLog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text("Save Recovery Log"),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getPainEmoji(int level) {
    if (level <= 2) return "😊";
    if (level <= 4) return "😐";
    if (level <= 6) return "😟";
    if (level <= 8) return "😣";
    return "😫";
  }

  String _getMoodEmoji(String mood) {
    switch (mood) {
      case "great": return "😄";
      case "good": return "🙂";
      case "okay": return "😐";
      case "tired": return "😴";
      case "overwhelmed": return "😰";
      case "sad": return "😢";
      case "anxious": return "😟";
      default: return "😐";
    }
  }

  Color _getBleedingColor(String bleeding) {
    switch (bleeding) {
      case "heavy": return Colors.red.shade700;
      case "moderate": return Colors.red.shade400;
      case "light": return Colors.red.shade200;
      case "spotting": return Colors.red.shade100;
      case "none": return Colors.green;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recovery Tracking"),
        backgroundColor: Colors.pink.shade100,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddLogDialog,
        icon: const Icon(Icons.add),
        label: const Text("Log Recovery"),
        backgroundColor: Colors.pink,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pink.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _recoveryLogs.isEmpty
                ? _buildEmptyState()
                : _buildLogsList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            "No recovery logs yet",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Track your postnatal recovery journey",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildLogsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _recoveryLogs.length,
      itemBuilder: (context, index) {
        final log = _recoveryLogs[index];
        final date = DateTime.tryParse(log['date'] ?? '');
        final dateStr = date != null ? DateFormat('MMM d, yyyy').format(date) : "Unknown";
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateStr,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    "${_getMoodEmoji(log['mood'] ?? 'okay')} ${log['mood'] ?? ''}",
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildMiniStat("Pain", "${log['pain_level'] ?? '-'}/10", Colors.red.shade100),
                  const SizedBox(width: 8),
                  _buildMiniStat("Sleep", "${log['sleep_hours'] ?? '-'}h", Colors.blue.shade100),
                  const SizedBox(width: 8),
                  _buildMiniStat(
                    "Bleeding",
                    log['bleeding'] ?? '-',
                    _getBleedingColor(log['bleeding'] ?? '').withOpacity(0.3),
                  ),
                ],
              ),
              if (log['breastfeeding_issues'] != null && log['breastfeeding_issues'].isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  "Breastfeeding: ${log['breastfeeding_issues']}",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
              if (log['notes'] != null && log['notes'].isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  log['notes'],
                  style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.black54)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}
