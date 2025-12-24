import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:project_frontend/constants.dart';
import 'package:project_frontend/models/tracking_models.dart';
import 'package:project_frontend/models/kick_count_notes.dart';
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

  // New session features
  int _selectedIntensity = 3; // Default to medium intensity (1-5 scale)
  Set<String> _selectedContextTags = {}; // Context tags
  final TextEditingController _diaryNotesController = TextEditingController();

  // Available context tags for filtering/contextualizing kicks
  static const List<String> availableContextTags = [
    'After Meal',
    'Before Sleep',
    'Cold Drink',
    'Morning',
    'Afternoon',
    'Evening',
    'Exercise',
    'Resting',
    'Happy Moment',
    'Music Playing',
  ];

  @override
  void initState() {
    super.initState();
    _fetchKickCounts();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _diaryNotesController.dispose();
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
      // Haptic feedback on every kick
      HapticFeedback.lightImpact();

      setState(() {
        _currentKicks++;
      });
    }
  }

  Future<void> _finishSession() async {
    _timer?.cancel();
    final durationSeconds = _elapsed.inSeconds;
    final durationMinutes = (durationSeconds / 60).toInt();

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
          "duration_seconds": durationSeconds,
          "notes": "Session finished",
          "average_intensity": _selectedIntensity,
          "context_tags": _selectedContextTags.toList(),
          "diary_notes": _diaryNotesController.text.isNotEmpty
              ? _diaryNotesController.text
              : null,
        }),
      );

      if (response.statusCode == 201) {
        if (mounted) {
          _fetchKickCounts();
          _resetSession();
          // Show kick count results with guidance notes - pass duration in seconds for accurate calculation
          _showKickCountResults(_currentKicks, durationSeconds);
        }
      } else {
        print("Failed to save kick session: ${response.body}");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to save session")),
          );
        }
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

  void _showKickCountResults(int kickCount, int durationSeconds) {
    final notes = KickCountGuidance.getKickCountNotes(
      kickCount,
      durationSeconds,
      pregnancyWeek: 28,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Column(
            children: [
              Text(
                notes.icon,
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 12),
              Text(
                notes.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Summary stats
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _getStatusColor(notes.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            '$kickCount',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Kicks',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      Container(
                        height: 40,
                        width: 1,
                        color: Colors.grey.shade300,
                      ),
                      Column(
                        children: [
                          Text(
                            (durationSeconds / 60).toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Minutes',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Message
                Text(
                  notes.message,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 16),
                // Additional tips if status is concerning or monitor
                if (notes.status == KickCountStatus.concerning ||
                    notes.status == KickCountStatus.monitor) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.info, size: 18, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              'Pro Tip',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Every baby has unique patterns. If you\'re concerned about any changes from what\'s normal for YOUR baby, contact your healthcare provider.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 18,
                              color: Colors.green,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Keep It Up!',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Continue monitoring daily at the same time. Your awareness of normal patterns is the best health tool!',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showKickCountingGuidance();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Learn More'),
            ),
          ],
        );
      },
    );
  }

  Color _getStatusColor(KickCountStatus status) {
    switch (status) {
      case KickCountStatus.excellent:
      case KickCountStatus.good:
        return Colors.green;
      case KickCountStatus.monitor:
        return Colors.orange;
      case KickCountStatus.concerning:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(KickCountStatus status) {
    switch (status) {
      case KickCountStatus.excellent:
      case KickCountStatus.good:
        return Icons.check_circle;
      case KickCountStatus.monitor:
        return Icons.schedule;
      case KickCountStatus.concerning:
        return Icons.warning;
    }
  }

  void _showKickCountResultsFromLog(int kickCount, int durationSeconds) {
    _showKickCountResults(kickCount, durationSeconds);
  }

  void _showKickCountingGuidance() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (BuildContext context, ScrollController scrollController) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: ListView(
                controller: scrollController,
                children: [
                  const Text(
                    'Kick Counting Guide',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildGuidanceSection(
                    'About Fetal Movements',
                    KickCountGuidance.kickCountFeels,
                  ),
                  const SizedBox(height: 24),
                  _buildGuidanceSection(
                    'Kick Counting Tips',
                    KickCountGuidance.kickCountingTips,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Remember:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'You know your baby best. Trust your instincts and always feel comfortable reaching out to your healthcare provider with any concerns about fetal movement.',
                          style: TextStyle(height: 1.6),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGuidanceSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: const TextStyle(
            fontSize: 13,
            height: 1.8,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  void _resetSession() {
    setState(() {
      _selectedIntensity = 3;
      _selectedContextTags.clear();
      _diaryNotesController.clear();
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
                      // Calculate duration from actual timestamps (most accurate)
                      // This works even for old logs without stored duration_seconds
                      final durationSeconds = log.date
                          .difference(log.startTime)
                          .inSeconds;
                      final notes = KickCountGuidance.getKickCountNotes(
                        log.kickCount,
                        durationSeconds,
                      );
                      final statusColor = _getStatusColor(notes.status);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          onTap: () {
                            _showKickCountResultsFromLog(
                              log.kickCount,
                              durationSeconds,
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: statusColor.withOpacity(0.2),
                                  child: Icon(
                                    _getStatusIcon(notes.status),
                                    color: statusColor,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${log.kickCount} kicks",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        "${log.date.day}/${log.date.month}/${log.date.year} • ${log.durationMinutes ?? 0} mins",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Chip(
                                        label: Text(
                                          notes.status ==
                                                  KickCountStatus.excellent
                                              ? 'Excellent'
                                              : notes.status ==
                                                    KickCountStatus.good
                                              ? 'Good'
                                              : notes.status ==
                                                    KickCountStatus.monitor
                                              ? 'Monitor'
                                              : 'Concerning',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        backgroundColor: statusColor,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Colors.grey.shade400,
                                ),
                              ],
                            ),
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
