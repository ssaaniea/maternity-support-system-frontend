import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:project_frontend/apiService.dart';
import 'package:project_frontend/providers/user_stage_provider.dart';
import 'package:provider/provider.dart';

class SleepScreen extends StatefulWidget {
  const SleepScreen({super.key});

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  bool _isLoading = true;
  bool _isSubmitting = false;
  List<Map<String, dynamic>> _sleepLogs = [];

  DateTime? _startTime;
  DateTime? _endTime;
  String _selectedQuality = 'good';
  final TextEditingController _notesController = TextEditingController();

  final List<Map<String, String>> _qualities = [
    {'value': 'good', 'label': '😴 Good'},
    {'value': 'fair', 'label': '😐 Fair'},
    {'value': 'poor', 'label': '😫 Poor'},
  ];

  @override
  void initState() {
    super.initState();
    _loadSleepLogs();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadSleepLogs() async {
    final provider = context.read<UserStageProvider>();
    final babyId = provider.selectedBabyId;

    if (babyId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await ApiService().get('/baby/$babyId/sleep');

      if (response.statusCode == 200) {
        final rawData = response.data;
        final list = (rawData is Map && rawData['data'] != null)
            ? rawData['data']
            : (rawData is List ? rawData : []);

        if (mounted) {
          setState(() {
            _sleepLogs = List<Map<String, dynamic>>.from(list);
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading sleep logs: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickTime(bool isStart) async {
    final now = DateTime.now();
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now),
    );

    if (time != null) {
      setState(() {
        final picked = DateTime(
          now.year,
          now.month,
          now.day,
          time.hour,
          time.minute,
        );
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _logSleep() async {
    if (_startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and end time')),
      );
      return;
    }

    final provider = context.read<UserStageProvider>();
    final babyId = provider.selectedBabyId;

    if (babyId == null) return;

    // Dismiss keyboard immediately
    FocusScope.of(context).unfocus();

    setState(() => _isSubmitting = true);

    try {
      final response = await ApiService().post(
        '/baby/$babyId/sleep',
        body: {
          'start_time': _startTime!.toIso8601String(),
          'end_time': _endTime!.toIso8601String(),
          'quality': _selectedQuality,
          'notes': _notesController.text,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        _startTime = null;
        _endTime = null;
        _notesController.clear();
        await _loadSleepLogs();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Sleep logged successfully!'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error logging sleep: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to log sleep'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }

    if (mounted) setState(() => _isSubmitting = false);
  }

  String _formatDuration(Map<String, dynamic> log) {
    try {
      final start = DateTime.parse(log['start_time']);
      final end = DateTime.parse(log['end_time']);
      final diff = end.difference(start);
      final hours = diff.inHours;
      final minutes = diff.inMinutes % 60;
      return '${hours}h ${minutes}m';
    } catch (_) {
      return '--';
    }
  }

  String _formatTimeRange(Map<String, dynamic> log) {
    try {
      final start = DateTime.parse(log['start_time']);
      final end = DateTime.parse(log['end_time']);
      final startStr = DateFormat('h:mm a').format(start);
      final endStr = DateFormat('h:mm a').format(end);
      return '$startStr - $endStr';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Sleep Tracker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLogSection(),
            const SizedBox(height: 24),
            const Text(
              'Sleep History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_sleepLogs.isEmpty)
              _buildEmptyState()
            else
              ..._sleepLogs.take(20).map(_buildSleepCard),
          ],
        ),
      ),
    );
  }

  Widget _buildLogSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Log Sleep',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Time pickers
          Row(
            children: [
              Expanded(
                child: _buildTimePicker(
                  label: 'Start Time',
                  value: _startTime,
                  onTap: () => _pickTime(true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTimePicker(
                  label: 'End Time',
                  value: _endTime,
                  onTap: () => _pickTime(false),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Quality
          Wrap(
            spacing: 8,
            children: _qualities.map((q) {
              final isSelected = _selectedQuality == q['value'];
              return ChoiceChip(
                label: Text(q['label']!),
                selected: isSelected,
                onSelected: (_) =>
                    setState(() => _selectedQuality = q['value']!),
                selectedColor: Colors.indigo.shade100,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.indigo : Colors.grey[700],
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          TextField(
            controller: _notesController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Notes (optional)',
              prefixIcon: const Icon(Iconsax.note),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _logSleep,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Log Sleep',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePicker({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Iconsax.clock, color: Colors.indigo, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                  ),
                  Text(
                    value != null
                        ? DateFormat('h:mm a').format(value)
                        : 'Select',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepCard(Map<String, dynamic> log) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.indigo.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Iconsax.moon, color: Colors.indigo, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatTimeRange(log),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  'Quality: ${log['quality'] ?? '--'}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            _formatDuration(log),
            style: TextStyle(
              color: Colors.indigo,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Iconsax.moon, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text('No sleep logs yet', style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }
}
