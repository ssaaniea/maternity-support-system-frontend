import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:project_frontend/constants.dart';
import 'package:project_frontend/screens/mother/signup_details.dart';
import 'package:project_frontend/screens/mother/tracking/checkup_screen.dart';
import 'package:project_frontend/screens/mother/tracking/kick_count_screen.dart';
import 'package:project_frontend/screens/mother/tracking/recovery_screen.dart';
import 'package:project_frontend/screens/mother/tracking/symptom_screen.dart';
import 'package:project_frontend/screens/mother/tracking/weight_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

// Unified journal entry model
class JournalEntry {
  final String type; // weight, symptom, kick, checkup, recovery
  final DateTime date;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  JournalEntry({
    required this.type,
    required this.date,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

class _TrackingScreenState extends State<TrackingScreen> {
  bool _isLoading = true;
  bool _hasProfile = false;

  // Profile data
  String _status = "pregnant";
  int? _pregnancyWeek;
  String? _name;

  // Journal entries
  List<JournalEntry> _journalEntries = [];

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("jwt_token");
      if (token == null) {
        setState(() => _isLoading = false);
        return;
      }

      final response = await http.get(
        Uri.parse('$kBaseRoute/mother/me/profile'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final profile = data['data'];

        // Extract journal entries
        List<JournalEntry> entries = [];

        // Weight logs
        final weightLogs = profile['weight_logs'] as List? ?? [];
        for (var log in weightLogs) {
          final date = DateTime.tryParse(log['date'] ?? '');
          if (date != null) {
            entries.add(
              JournalEntry(
                type: 'weight',
                date: date,
                title: '${log['weight_kg']} kg',
                subtitle: log['notes'] ?? 'Weight logged',
                icon: Iconsax.weight,
                color: Colors.teal,
              ),
            );
          }
        }

        // Symptom logs
        final symptomLogs = profile['symptom_logs'] as List? ?? [];
        for (var log in symptomLogs) {
          final date = DateTime.tryParse(log['date'] ?? '');
          if (date != null) {
            final symptoms = (log['symptoms'] as List?)?.join(', ') ?? '';
            entries.add(
              JournalEntry(
                type: 'symptom',
                date: date,
                title: log['mood'] ?? 'Symptoms',
                subtitle: symptoms.isNotEmpty ? symptoms : 'Symptoms logged',
                icon: Iconsax.health,
                color: Colors.purple,
              ),
            );
          }
        }

        // Kick counts
        final kickCounts = profile['kick_counts'] as List? ?? [];
        for (var log in kickCounts) {
          final date = DateTime.tryParse(log['date'] ?? '');
          if (date != null) {
            entries.add(
              JournalEntry(
                type: 'kick',
                date: date,
                title: '${log['kick_count']} kicks',
                subtitle: log['notes'] ?? 'Baby movement tracked',
                icon: Iconsax.happyemoji,
                color: Colors.orange,
              ),
            );
          }
        }

        // Checkup logs
        final checkupLogs = profile['checkup_logs'] as List? ?? [];
        for (var log in checkupLogs) {
          final date = DateTime.tryParse(log['date'] ?? '');
          if (date != null) {
            entries.add(
              JournalEntry(
                type: 'checkup',
                date: date,
                title: log['doctor_name'] ?? 'Doctor Checkup',
                subtitle: log['hospital_name'] ?? 'Checkup completed',
                icon: Iconsax.hospital,
                color: Colors.green,
              ),
            );
          }
        }

        // Recovery logs
        final recoveryLogs = profile['recovery_logs'] as List? ?? [];
        for (var log in recoveryLogs) {
          final date = DateTime.tryParse(log['date'] ?? '');
          if (date != null) {
            entries.add(
              JournalEntry(
                type: 'recovery',
                date: date,
                title: 'Pain: ${log['pain_level']}/10',
                subtitle:
                    'Mood: ${log['mood']} • Sleep: ${log['sleep_hours']}h',
                icon: Iconsax.heart,
                color: Colors.red,
              ),
            );
          }
        }

        // Sort by date descending
        entries.sort((a, b) => b.date.compareTo(a.date));

        setState(() {
          _hasProfile = true;
          _name = profile['name'];
          _status = profile['status'] ?? "pregnant";
          _pregnancyWeek = data['pregnancy_week'];
          _journalEntries = entries;
          _isLoading = false;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _hasProfile = false;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print("Error fetching profile: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_hasProfile) {
      return _buildNoProfileScreen();
    }

    final isPregnant = _status == "pregnant";

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "My Journal",
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(
              isPregnant
                  ? "Week ${_pregnancyWeek ?? '-'} of pregnancy"
                  : "Postnatal recovery",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh, color: Colors.black54),
            onPressed: _fetchProfile,
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick action buttons
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickButton(
                  icon: Iconsax.weight,
                  label: "Weight",
                  color: Colors.teal,
                  onTap: () => _navigateAndRefresh(const WeightScreen()),
                ),
                _buildQuickButton(
                  icon: Iconsax.health,
                  label: "Symptoms",
                  color: Colors.purple,
                  onTap: () => _navigateAndRefresh(const SymptomScreen()),
                ),
                _buildQuickButton(
                  icon: isPregnant ? Iconsax.happyemoji : Iconsax.heart,
                  label: isPregnant ? "Kicks" : "Recovery",
                  color: isPregnant ? Colors.orange : Colors.red,
                  onTap: () => _navigateAndRefresh(
                    isPregnant
                        ? const KickCountScreen()
                        : const RecoveryScreen(),
                  ),
                ),
                _buildQuickButton(
                  icon: Iconsax.hospital,
                  label: "Checkup",
                  color: Colors.green,
                  onTap: () => _navigateAndRefresh(const CheckupScreen()),
                ),
              ],
            ),
          ),

          // Divider
          Container(
            height: 1,
            color: Colors.grey[200],
          ),

          // Journal title
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Iconsax.document_text, size: 20),
                const SizedBox(width: 8),
                Text(
                  "Recent Entries",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.grey[800],
                  ),
                ),
                const Spacer(),
                Text(
                  "${_journalEntries.length} total",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),

          // Journal list
          Expanded(
            child: _journalEntries.isEmpty
                ? _buildEmptyJournal()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _journalEntries.length,
                    itemBuilder: (context, index) {
                      return _buildJournalCard(_journalEntries[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _navigateAndRefresh(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    ).then((_) => _fetchProfile());
  }

  Widget _buildQuickButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJournalCard(JournalEntry entry) {
    final dateStr = DateFormat('MMM d, yyyy').format(entry.date);
    final timeStr = DateFormat('h:mm a').format(entry.date);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: entry.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(entry.icon, color: entry.color, size: 22),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      entry.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      timeStr,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  entry.subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyJournal() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.document, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "No entries yet",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Start tracking to see your journal",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoProfileScreen() {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Iconsax.user_add,
                size: 80,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              const Text(
                "Profile Not Found",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Please complete your profile to start tracking.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SignupDetails()),
                  ).then((_) => _fetchProfile());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text("Complete Profile"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
