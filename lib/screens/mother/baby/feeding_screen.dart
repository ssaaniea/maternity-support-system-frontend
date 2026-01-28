import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:project_frontend/apiService.dart';
import 'package:project_frontend/providers/user_stage_provider.dart';
import 'package:provider/provider.dart';

class FeedingScreen extends StatefulWidget {
  const FeedingScreen({super.key});

  @override
  State<FeedingScreen> createState() => _FeedingScreenState();
}

class _FeedingScreenState extends State<FeedingScreen> {
  bool _isLoading = true;
  bool _isSubmitting = false;
  List<Map<String, dynamic>> _feedingLogs = [];

  String _selectedType = 'breast';
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  final List<Map<String, dynamic>> _feedTypes = [
    {'value': 'breast', 'label': 'Breast', 'icon': Iconsax.heart},
    {'value': 'bottle', 'label': 'Bottle', 'icon': Iconsax.milk},
    {'value': 'formula', 'label': 'Formula', 'icon': Iconsax.coffee},
    {'value': 'solid', 'label': 'Solid', 'icon': Iconsax.cake},
  ];

  @override
  void initState() {
    super.initState();
    _loadFeedings();
  }

  @override
  void dispose() {
    _durationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadFeedings() async {
    final provider = context.read<UserStageProvider>();
    final babyId = provider.selectedBabyId;

    if (babyId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await ApiService().get('/baby/$babyId/feeding');

      if (response.statusCode == 200) {
        final rawData = response.data;
        // Handle nesting if present, usually in 'data' field for this API
        final list = (rawData is Map && rawData['data'] != null)
            ? rawData['data']
            : (rawData is List ? rawData : []);

        if (mounted) {
          setState(() {
            _feedingLogs = List<Map<String, dynamic>>.from(list);
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading feedings: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logFeeding() async {
    final provider = context.read<UserStageProvider>();
    final babyId = provider.selectedBabyId;

    if (babyId == null) return;

    // Dismiss keyboard immediately
    FocusScope.of(context).unfocus();

    final duration = int.tryParse(_durationController.text) ?? 15;

    setState(() => _isSubmitting = true);

    try {
      final response = await ApiService().post(
        '/baby/$babyId/feeding',
        body: {
          'type': _selectedType,
          'start_time': DateTime.now().toIso8601String(),
          'duration_minutes': duration,
          'notes': _notesController.text,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        _durationController.clear();
        _notesController.clear();
        await _loadFeedings();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Feeding logged successfully!'),
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
      debugPrint('Error logging feeding: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to log feeding'),
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

  String _formatTime(String? isoTime) {
    if (isoTime == null) return '';
    try {
      final dt = DateTime.parse(isoTime).toLocal();
      return DateFormat('MMM d, h:mm a').format(dt);
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
          'Feeding Tracker',
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
            // Log New Feeding
            _buildLogSection(),

            const SizedBox(height: 24),

            // Feeding History
            const Text(
              'Feeding History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_feedingLogs.isEmpty)
              _buildEmptyState()
            else
              ..._feedingLogs.take(20).map(_buildFeedingCard),
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
            'Log Feeding',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Feed Type Selection
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _feedTypes.map((type) {
              final isSelected = _selectedType == type['value'];
              return ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      type['icon'],
                      size: 16,
                      color: isSelected ? Colors.white : Colors.orange,
                    ),
                    const SizedBox(width: 6),
                    Text(type['label']),
                  ],
                ),
                selected: isSelected,
                onSelected: (_) =>
                    setState(() => _selectedType = type['value']),
                selectedColor: Colors.orange,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[700],
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Duration
          TextField(
            controller: _durationController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Duration (minutes)',
              hintText: '15',
              prefixIcon: const Icon(Iconsax.timer_1),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Notes
          TextField(
            controller: _notesController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Notes (optional)',
              hintText: 'Fed well, was hungry...',
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

          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _logFeeding,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
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
                      'Log Feeding',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedingCard(Map<String, dynamic> log) {
    final type = log['type'] ?? 'breast';
    final icon = _feedTypes.firstWhere(
      (t) => t['value'] == type,
      orElse: () => _feedTypes.first,
    )['icon'];
    final notes = log['notes']?.toString().trim();

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
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.orange, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type[0].toUpperCase() + type.substring(1),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  _formatTime(log['start_time']),
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                if (notes != null && notes.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      notes,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            '${log['duration_minutes'] ?? '--'} min',
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
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
          Icon(Iconsax.milk, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            'No feedings logged yet',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
