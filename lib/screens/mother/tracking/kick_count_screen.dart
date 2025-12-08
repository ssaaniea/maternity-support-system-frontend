import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:project_frontend/constants.dart';
import 'package:project_frontend/models/tracking_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KickCountScreen extends StatefulWidget {
  const KickCountScreen({super.key});

  @override
  State<KickCountScreen> createState() => _KickCountScreenState();
}

class _KickCountScreenState extends State<KickCountScreen> {
  bool _isLoading = true;
  List<KickCountLog> _logs = [];

  // Active session state
  bool _isSessionActive = false;
  DateTime? _startTime;
  int _currentKicks = 0;
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _fetchKickCounts();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchKickCounts() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("jwt_token");
      if (token == null) {
        setState(() => _isLoading = false);
        return;
      }

      final url = Uri.parse('$kBaseRoute/mother/me/kick-counts');
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
            .map((e) => KickCountLog.fromJson(e))
            .toList();
        setState(() {
          _logs = list;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print("Error fetching kicks: $e");
      setState(() => _isLoading = false);
    }
  }

  void _startSession() {
    setState(() {
      _isSessionActive = true;
      _startTime = DateTime.now();
      _currentKicks = 0;
      _elapsed = Duration.zero;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsed = Duration(seconds: timer.tick);
      });
    });
  }

  void _incrementKick() {
    if (_isSessionActive) {
      setState(() {
        _currentKicks++;
      });
    }
  }

  Future<void> _finishSession() async {
    _timer?.cancel();
    final durationMinutes = _elapsed.inMinutes;

    // Save to backend
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("jwt_token");
      if (token == null) return;

      final url = Uri.parse('$kBaseRoute/mother/me/kick-counts');
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "date": DateTime.now().toIso8601String(),
          "start_time": _startTime!.toIso8601String(),
          "kick_count": _currentKicks,
          "duration_minutes": durationMinutes,
          "notes": "Session finished",
        }),
      );

      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Session saved!")),
          );
        }
        _fetchKickCounts();
      } else {
        print("Failed to save kick session: ${response.body}");
      }
    } catch (e) {
      print("Error saving kick session: $e");
    }

    setState(() {
      _isSessionActive = false;
      _currentKicks = 0;
      _elapsed = Duration.zero;
    });
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kick Counter"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: [
          // Active Session Card
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _isSessionActive ? Colors.orange.shade50 : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.orange.shade100, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  if (!_isSessionActive) ...[
                    const Icon(
                      Icons.touch_app_rounded,
                      size: 48,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Start a new kick counting session",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _startSession,
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text("Start Session"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ] else ...[
                    Text(
                      _formatDuration(_elapsed),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text("Elapsed Time"),
                    const SizedBox(height: 24),
                    Text(
                      "$_currentKicks",
                      style: const TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text("Kicks Recorded"),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _incrementKick,
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(24),
                            backgroundColor: Colors.orange,
                          ),
                          child: const Icon(
                            Icons.add,
                            size: 32,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 24),
                        OutlinedButton(
                          onPressed: _finishSession,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                          ),
                          child: const Text("Finish"),
                        ),
                      ],
                    ),
                    const Text(
                      "Tap + to count a kick",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        height: 2,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _logs.isEmpty
                ? const Center(child: Text("No sessions recorded yet."))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _logs.length,
                    itemBuilder: (context, index) {
                      final log = _logs[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.orange,
                            child: Icon(Icons.child_care, color: Colors.white),
                          ),
                          title: Text("${log.kickCount} kicks"),
                          subtitle: Text(
                            "${log.date.day}/${log.date.month} • ${log.durationMinutes ?? 0} mins",
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
