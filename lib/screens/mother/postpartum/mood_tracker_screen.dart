import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:project_frontend/apiService.dart';

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  bool _isLoading = true;
  bool _isSubmitting = false;
  List<Map<String, dynamic>> _moodLogs = [];

  String? _selectedMood;
  final TextEditingController _notesController = TextEditingController();

  final List<Map<String, dynamic>> _moods = [
    {'value': 'happy', 'emoji': '😊', 'label': 'Happy', 'color': Colors.green},
    {'value': 'calm', 'emoji': '😌', 'label': 'Calm', 'color': Colors.blue},
    {
      'value': 'anxious',
      'emoji': '😰',
      'label': 'Anxious',
      'color': Colors.orange,
    },
    {'value': 'sad', 'emoji': '😢', 'label': 'Sad', 'color': Colors.indigo},
    {'value': 'tired', 'emoji': '😴', 'label': 'Tired', 'color': Colors.grey},
    {
      'value': 'irritable',
      'emoji': '😤',
      'label': 'Irritable',
      'color': Colors.red,
    },
    {
      'value': 'excited',
      'emoji': '🤗',
      'label': 'Excited',
      'color': Colors.purple,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadMoodLogs();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadMoodLogs() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService().get('/mother/me/mood-logs');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          _moodLogs = List<Map<String, dynamic>>.from(data);
        } else if (data is Map && data['data'] is List) {
          _moodLogs = List<Map<String, dynamic>>.from(data['data']);
        }
        // Sort by date descending (most recent first)
        _moodLogs.sort((a, b) {
          final dateA = DateTime.tryParse(a['date'] ?? '') ?? DateTime(1970);
          final dateB = DateTime.tryParse(b['date'] ?? '') ?? DateTime(1970);
          return dateB.compareTo(dateA);
        });
      }
      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('Error loading mood logs: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logMood() async {
    if (_selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a mood')),
      );
      return;
    }

    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    setState(() => _isSubmitting = true);

    try {
      final response = await ApiService().post(
        '/mother/me/mood-logs',
        body: {'mood': _selectedMood, 'notes': _notesController.text},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _selectedMood = null;
        _notesController.clear();
        await _loadMoodLogs();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.favorite, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('Mood logged! Keep tracking your feelings 💜'),
                  ),
                ],
              ),
              backgroundColor: Colors.purple,
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
      debugPrint('Error logging mood: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to log mood'),
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

  Map<String, dynamic> _getMoodData(String mood) {
    return _moods.firstWhere(
      (m) => m['value'] == mood,
      orElse: () => _moods.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Mood Tracker',
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
            // Mental health tip
            _buildMentalHealthTip(),
            const SizedBox(height: 20),

            // Log mood
            _buildLogSection(),
            const SizedBox(height: 24),

            // Mood history
            const Text(
              'Your Mood Journey',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_moodLogs.isEmpty)
              _buildEmptyState()
            else
              ..._moodLogs.take(15).map(_buildMoodCard),
          ],
        ),
      ),
    );
  }

  Widget _buildMentalHealthTip() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade300, Colors.purple.shade100],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text('💜', style: TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Mental Health Matters',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Tracking your mood helps you understand your emotional patterns.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
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
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How are you feeling today?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Mood selection
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _moods.map((mood) {
              final isSelected = _selectedMood == mood['value'];
              return GestureDetector(
                onTap: () => setState(() => _selectedMood = mood['value']),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (mood['color'] as Color).withOpacity(0.15)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? mood['color'] as Color
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(mood['emoji'], style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 6),
                      Text(
                        mood['label'],
                        style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? mood['color'] as Color
                              : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'What\'s on your mind? (optional)',
              hintText: 'Share your thoughts...',
              prefixIcon: const Icon(Iconsax.message),
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
              onPressed: _isSubmitting ? null : _logMood,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
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
                      'Log Mood',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodCard(Map<String, dynamic> log) {
    final mood = _getMoodData(log['mood'] ?? 'happy');
    final date = DateTime.tryParse(log['date'] ?? '')?.toLocal();

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
              color: (mood['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(mood['emoji'], style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mood['label'],
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (log['notes']?.isNotEmpty == true)
                  Text(
                    log['notes'],
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Text(
            date != null ? DateFormat('MMM d, h:mm a').format(date) : '',
            style: TextStyle(color: Colors.grey[400], fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Iconsax.emoji_happy, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              'Start tracking your mood',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}
