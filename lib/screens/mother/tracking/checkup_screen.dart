import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:project_frontend/constants.dart';
import 'package:project_frontend/models/tracking_models.dart';
import 'package:project_frontend/widgets/tracking_widgets.dart';
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
    required DateTime date,
    required String doctorName,
    required String hospitalName,
    double? weight,
    String? bp,
    int? heartRate,
    String? notes,
    DateTime? nextCheckupDate,
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
          "date": date.toIso8601String(),
          "doctor_name": doctorName,
          "hospital_name": hospitalName,
          "weight_kg": weight,
          "blood_pressure": bp,
          "baby_heart_rate": heartRate,
          "notes": notes,
          "next_checkup_date": nextCheckupDate?.toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Iconsax.tick_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text("Checkup logged successfully!"),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
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

    DateTime selectedDate = DateTime.now();
    DateTime? nextCheckupDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.9,
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
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Iconsax.hospital,
                        color: Colors.green,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        "Log Checkup",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Iconsax.close_circle),
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
              Divider(color: Colors.grey[200], height: 1),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date section
                      const TrackingSectionHeader(
                        title: "Appointment Details",
                        icon: Iconsax.calendar,
                      ),
                      TrackingDateField(
                        label: "Checkup Date",
                        selectedDate: selectedDate,
                        icon: Iconsax.calendar_1,
                        onDateSelected: (date) {
                          setModalState(() => selectedDate = date);
                        },
                      ),
                      TrackingDateField(
                        label: "Next Checkup Date (Optional)",
                        selectedDate: nextCheckupDate,
                        icon: Iconsax.calendar_tick,
                        firstDate: DateTime.now(),
                        onDateSelected: (date) {
                          setModalState(() => nextCheckupDate = date);
                        },
                      ),

                      const TrackingSectionHeader(
                        title: "Doctor & Location",
                        icon: Iconsax.user_octagon,
                      ),
                      TrackingTextField(
                        controller: doctorController,
                        label: "Doctor Name",
                        icon: Iconsax.user,
                        hint: "e.g., Dr. Smith",
                      ),
                      TrackingTextField(
                        controller: hospitalController,
                        label: "Hospital / Clinic",
                        icon: Iconsax.hospital,
                        hint: "e.g., City Hospital",
                      ),

                      const TrackingSectionHeader(
                        title: "Health Measurements",
                        icon: Iconsax.health,
                      ),
                      TrackingRowFields(
                        left: TrackingTextField(
                          controller: weightController,
                          label: "Weight",
                          suffix: "kg",
                          keyboardType: TextInputType.number,
                          icon: Iconsax.weight,
                        ),
                        right: TrackingTextField(
                          controller: bpController,
                          label: "Blood Pressure",
                          hint: "e.g., 120/80",
                          icon: Iconsax.activity,
                        ),
                      ),
                      TrackingTextField(
                        controller: heartRateController,
                        label: "Baby Heart Rate",
                        suffix: "bpm",
                        keyboardType: TextInputType.number,
                        icon: Iconsax.heart,
                      ),

                      const TrackingSectionHeader(
                        title: "Notes",
                        icon: Iconsax.note_1,
                      ),
                      TrackingTextField(
                        controller: notesController,
                        label: "Additional Notes",
                        hint: "Any observations or recommendations...",
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              // Save button
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (doctorController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please enter doctor name"),
                          ),
                        );
                        return;
                      }

                      _addCheckup(
                        date: selectedDate,
                        doctorName: doctorController.text,
                        hospitalName: hospitalController.text,
                        weight: double.tryParse(weightController.text),
                        bp: bpController.text.isNotEmpty
                            ? bpController.text
                            : null,
                        heartRate: int.tryParse(heartRateController.text),
                        notes: notesController.text.isNotEmpty
                            ? notesController.text
                            : null,
                        nextCheckupDate: nextCheckupDate,
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Save Checkup",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Checkups",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        label: const Text(
          "Log Checkup",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Iconsax.add),
        backgroundColor: Colors.green,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _logs.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _logs.length,
              itemBuilder: (context, index) {
                return _buildCheckupCard(_logs[index]);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.hospital, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "No checkups logged yet",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Tap the button below to log your first checkup",
            style: TextStyle(color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckupCard(CheckupLog log) {
    final dateStr = DateFormat('EEEE, MMM d, yyyy').format(log.date);
    final hasNextCheckup = log.nextCheckupDate != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Iconsax.hospital,
                    color: Colors.green,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Dr. ${log.doctorName ?? 'Unknown'}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        log.hospitalName ?? "Hospital",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Iconsax.tick_circle, color: Colors.green, size: 14),
                      SizedBox(width: 4),
                      Text(
                        "Done",
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Date
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(Iconsax.calendar_1, size: 16, color: Colors.grey[500]),
                const SizedBox(width: 8),
                Text(
                  dateStr,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          // Health stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildStatChip(
                  icon: Iconsax.weight,
                  value: log.weight != null ? "${log.weight} kg" : "-",
                  color: Colors.teal,
                ),
                const SizedBox(width: 8),
                _buildStatChip(
                  icon: Iconsax.heart,
                  value: log.babyHeartRate != null
                      ? "${log.babyHeartRate} bpm"
                      : "-",
                  color: Colors.pink,
                ),
                const SizedBox(width: 8),
                _buildStatChip(
                  icon: Iconsax.activity,
                  value: log.bloodPressure ?? "-",
                  color: Colors.orange,
                ),
              ],
            ),
          ),
          // Notes
          if (log.notes != null && log.notes!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Iconsax.note_1, size: 16, color: Colors.grey[500]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        log.notes!,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Next checkup
          if (hasNextCheckup)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Iconsax.calendar_tick,
                    size: 18,
                    color: Colors.blue[700],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Next Checkup: ",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    DateFormat('MMM d, yyyy').format(log.nextCheckupDate!),
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )
          else
            const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                value,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
