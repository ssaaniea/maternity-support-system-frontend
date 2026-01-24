import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:project_frontend/apiService.dart';
import 'package:project_frontend/providers/user_stage_provider.dart';
import 'package:project_frontend/screens/mother/baby/feeding_screen.dart';
import 'package:project_frontend/screens/mother/baby/sleep_screen.dart';
import 'package:project_frontend/screens/mother/baby/diaper_screen.dart';
import 'package:project_frontend/screens/mother/baby/vaccination_screen.dart';
import 'package:provider/provider.dart';

class BabyDashboard extends StatefulWidget {
  const BabyDashboard({super.key});

  @override
  State<BabyDashboard> createState() => _BabyDashboardState();
}

class _BabyDashboardState extends State<BabyDashboard> {
  bool _isLoading = true;
  Map<String, dynamic>? _todayStats;

  @override
  void initState() {
    super.initState();
    _loadTodayStats();
  }

  Future<void> _loadTodayStats() async {
    final provider = context.read<UserStageProvider>();
    final babyId = provider.selectedBabyId;

    if (babyId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      // Fetch today's logs in parallel
      final results = await Future.wait([
        ApiService().get('/baby/$babyId/feeding'),
        ApiService().get('/baby/$babyId/sleep'),
        ApiService().get('/baby/$babyId/diaper'),
      ]);

      final today = DateTime.now();
      final todayStr = DateFormat('yyyy-MM-dd').format(today);

      // Process feeding logs
      int feedCount = 0;
      String? lastFeedTime;
      if (results[0].statusCode == 200) {
        final data = results[0].data is String
            ? jsonDecode(results[0].data)
            : results[0].data;
        final feeds = (data is Map && data['data'] != null)
            ? (data['data'] as List)
            : <dynamic>[];
        for (var feed in feeds) {
          final feedDate = feed['start_time']?.toString().substring(0, 10);
          if (feedDate == todayStr) {
            feedCount++;
            lastFeedTime ??= feed['start_time'];
          }
        }
      }

      // Process sleep logs
      int totalSleepMinutes = 0;
      if (results[1].statusCode == 200) {
        final data = results[1].data is String
            ? jsonDecode(results[1].data)
            : results[1].data;
        final sleeps = (data is Map && data['data'] != null)
            ? (data['data'] as List)
            : <dynamic>[];
        for (var sleep in sleeps) {
          final sleepDate = sleep['start_time']?.toString().substring(0, 10);
          if (sleepDate == todayStr && sleep['end_time'] != null) {
            final start = DateTime.parse(sleep['start_time']);
            final end = DateTime.parse(sleep['end_time']);
            totalSleepMinutes += end.difference(start).inMinutes;
          }
        }
      }

      // Process diaper logs
      int diaperCount = 0;
      if (results[2].statusCode == 200) {
        final data = results[2].data is String
            ? jsonDecode(results[2].data)
            : results[2].data;
        final diapers = (data is Map && data['data'] != null)
            ? (data['data'] as List)
            : <dynamic>[];
        for (var diaper in diapers) {
          final diaperDate = diaper['time']?.toString().substring(0, 10);
          if (diaperDate == todayStr) {
            diaperCount++;
          }
        }
      }

      if (mounted) {
        setState(() {
          _todayStats = {
            'feedCount': feedCount,
            'lastFeedTime': lastFeedTime,
            'sleepHours': (totalSleepMinutes / 60).toStringAsFixed(1),
            'diaperCount': diaperCount,
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading baby stats in baby dashboard: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatTime(String? isoTime) {
    if (isoTime == null) return '--';
    try {
      final dt = DateTime.parse(isoTime);
      return DateFormat('h:mm a').format(dt);
    } catch (_) {
      return '--';
    }
  }

  String _getBabyAge(Map<String, dynamic> baby) {
    final birthDate = DateTime.tryParse(baby['birth_date'] ?? '');
    if (birthDate == null) return '';

    final now = DateTime.now();
    final days = now.difference(birthDate).inDays;

    if (days < 7) return '$days days old';
    if (days < 30) return '${(days / 7).floor()} weeks old';
    if (days < 365) return '${(days / 30).floor()} months old';
    return '${(days / 365).floor()} year${days >= 730 ? 's' : ''} old';
  }

  void _showDeleteConfirmation() {
    final provider = context.read<UserStageProvider>();
    final baby = provider.selectedBaby;
    if (baby == null) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Baby Profile'),
        content: Text(
          'Are you sure you want to delete ${baby['name']}\'s profile? This will permanently remove all feeding, sleep, diaper, and vaccination records. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteBaby(baby['_id']);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteBaby(String babyId) async {
    try {
      final response = await ApiService().delete('/baby/$babyId');

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Baby profile deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          // Refresh the provider to update babies list
          await context.read<UserStageProvider>().loadProfile();
          // Go back if no babies left
          if (context.read<UserStageProvider>().babies.isEmpty) {
            Navigator.pop(context);
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'Failed to delete baby'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Baby Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh),
            onPressed: _loadTodayStats,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Iconsax.more),
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteConfirmation();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Iconsax.trash, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('Delete Baby', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<UserStageProvider>(
        builder: (context, provider, _) {
          debugPrint(
            "BabyDashboard: Rebuilding with ${provider.babies.length} babies",
          );
          if (provider.babies.isEmpty) {
            debugPrint("BabyDashboard: No babies found");
            return _buildNoBabiesState();
          }

          final baby = provider.selectedBaby!;
          debugPrint("BabyDashboard: Selected baby: ${baby['name']}");

          return RefreshIndicator(
            onRefresh: _loadTodayStats,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Baby Switcher (if multiple babies)
                  if (provider.babies.length > 1) _buildBabySwitcher(provider),

                  // Baby Profile Card
                  _buildBabyProfileCard(baby),

                  const SizedBox(height: 20),

                  // Today's Summary
                  const Text(
                    "Today's Summary",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    _buildTodayStats(),

                  const SizedBox(height: 24),

                  // Quick Actions
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildQuickActions(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBabySwitcher(UserStageProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: provider.babies.map((baby) {
            final isSelected = baby['_id'] == provider.selectedBabyId;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(baby['name'] ?? 'Baby'),
                selected: isSelected,
                onSelected: (_) => provider.selectBaby(baby['_id']),
                selectedColor: Colors.pink.shade100,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.pink.shade700 : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                avatar: CircleAvatar(
                  backgroundColor: isSelected
                      ? Colors.pink
                      : Colors.grey.shade300,
                  child: Text(
                    (baby['name'] ?? 'B')[0].toUpperCase(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBabyProfileCard(Map<String, dynamic> baby) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.pink.shade300, Colors.pink.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(35),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Center(
              child: Text(
                baby['gender'] == 'male' ? '👶🏻' : '👶🏻',
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  baby['name'] ?? 'Baby',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getBabyAge(baby),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                if (baby['birth_weight'] != null)
                  Text(
                    'Birth weight: ${baby['birth_weight']}g',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Iconsax.milk,
            label: 'Feedings',
            value: '${_todayStats?['feedCount'] ?? 0}',
            subtitle: 'Last: ${_formatTime(_todayStats?['lastFeedTime'])}',
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Iconsax.moon,
            label: 'Sleep',
            value: '${_todayStats?['sleepHours'] ?? '0'}h',
            subtitle: 'Today total',
            color: Colors.indigo,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Iconsax.drop,
            label: 'Diapers',
            value: '${_todayStats?['diaperCount'] ?? 0}',
            subtitle: 'Changes',
            color: Colors.teal,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Iconsax.milk,
                label: 'Log Feeding',
                color: Colors.orange,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FeedingScreen()),
                  );
                  _loadTodayStats();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Iconsax.moon,
                label: 'Log Sleep',
                color: Colors.indigo,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SleepScreen()),
                  );
                  _loadTodayStats();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Iconsax.drop,
                label: 'Log Diaper',
                color: Colors.teal,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DiaperScreen()),
                  );
                  _loadTodayStats();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Iconsax.health,
                label: 'Vaccinations',
                color: Colors.red,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const VaccinationScreen(),
                    ),
                  );
                  _loadTodayStats();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoBabiesState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.happyemoji, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 24),
            Text(
              'No baby profiles yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your baby from the profile section to start tracking',
              style: TextStyle(color: Colors.grey[400]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
