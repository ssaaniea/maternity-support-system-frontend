import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:project_frontend/apiService.dart';
import 'package:project_frontend/providers/user_stage_provider.dart';
import 'package:provider/provider.dart';

class DiaperScreen extends StatefulWidget {
  const DiaperScreen({super.key});

  @override
  State<DiaperScreen> createState() => _DiaperScreenState();
}

class _DiaperScreenState extends State<DiaperScreen> {
  bool _isLoading = true;
  bool _isSubmitting = false;
  List<Map<String, dynamic>> _diaperLogs = [];

  String _selectedType = 'wet';
  final TextEditingController _notesController = TextEditingController();

  final List<Map<String, dynamic>> _diaperTypes = [
    {'value': 'wet', 'label': '💧 Wet', 'color': Colors.blue},
    {'value': 'dirty', 'label': '💩 Dirty', 'color': Colors.brown},
    {'value': 'both', 'label': '💧💩 Both', 'color': Colors.orange},
  ];

  @override
  void initState() {
    super.initState();
    _loadDiaperLogs();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadDiaperLogs() async {
    final provider = context.read<UserStageProvider>();
    final babyId = provider.selectedBabyId;

    if (babyId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await ApiService().get('/baby/$babyId/diaper');

      if (response.statusCode == 200) {
        final rawData = response.data;
        if (mounted) {
          setState(() {
            final list = (rawData is Map && rawData['data'] != null)
                ? rawData['data']
                : (rawData is List ? rawData : []);
            _diaperLogs = List<Map<String, dynamic>>.from(list);
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading diaper logs: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logDiaper() async {
    final provider = context.read<UserStageProvider>();
    final babyId = provider.selectedBabyId;

    if (babyId == null) return;

    // Dismiss keyboard immediately
    FocusScope.of(context).unfocus();

    setState(() => _isSubmitting = true);

    try {
      final response = await ApiService().post(
        '/baby/$babyId/diaper',
        body: {
          'type': _selectedType,
          'time': DateTime.now().toIso8601String(),
          'notes': _notesController.text,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        _notesController.clear();
        await _loadDiaperLogs();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Diaper change logged!'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error logging diaper: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to log diaper change'),
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

  int _getTodayCount() {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return _diaperLogs.where((log) {
      final logDate = log['time']?.toString().substring(0, 10);
      return logDate == today;
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Diaper Tracker',
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
            // Today's count
            _buildTodayCount(),

            const SizedBox(height: 16),

            // Quick log buttons
            _buildQuickLogSection(),

            const SizedBox(height: 24),

            // Diaper History
            const Text(
              'Diaper History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_diaperLogs.isEmpty)
              _buildEmptyState()
            else
              ..._diaperLogs.take(20).map(_buildDiaperCard),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayCount() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade400, Colors.teal.shade200],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Iconsax.drop, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Today's Diaper Changes",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${_getTodayCount()} changes',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLogSection() {
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
            'Quick Log',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Type selection
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _diaperTypes.map((type) {
              final isSelected = _selectedType == type['value'];
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Material(
                    color: isSelected
                        ? (type['color'] as Color).withOpacity(0.15)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () =>
                          setState(() => _selectedType = type['value']),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? type['color'] as Color
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              type['label']!.split(' ')[0],
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              type['label']!.split(' ').last,
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected
                                    ? type['color'] as Color
                                    : Colors.grey[600],
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          TextField(
            controller: _notesController,
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
              onPressed: _isSubmitting ? null : _logDiaper,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
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
                      'Log Diaper Change',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiaperCard(Map<String, dynamic> log) {
    final type = log['type'] ?? 'wet';
    final typeData = _diaperTypes.firstWhere(
      (t) => t['value'] == type,
      orElse: () => _diaperTypes.first,
    );
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
              color: (typeData['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              typeData['label']!.split(' ')[0],
              style: const TextStyle(fontSize: 18),
            ),
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
                  _formatTime(log['time']),
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
          Icon(Iconsax.drop, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            'No diaper changes logged yet',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
