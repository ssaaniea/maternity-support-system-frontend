import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:project_frontend/apiService.dart';
import 'package:project_frontend/providers/user_stage_provider.dart';
import 'package:provider/provider.dart';

class VaccinationScreen extends StatefulWidget {
  const VaccinationScreen({super.key});

  @override
  State<VaccinationScreen> createState() => _VaccinationScreenState();
}

class _VaccinationScreenState extends State<VaccinationScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _allVaccines = [];
  List<Map<String, dynamic>> _babyVaccinations = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final provider = context.read<UserStageProvider>();
    final babyId = provider.selectedBabyId;

    if (babyId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      // Fetch vaccine schedule and baby's vaccinations
      final results = await Future.wait([
        ApiService().get('/vaccine'),
        ApiService().get('/baby/$babyId/vaccination'),
      ]);

      if (results[0].statusCode == 200) {
        final data = results[0].data;
        final list = data is Map && data['data'] != null ? data['data'] : data;
        _allVaccines = List<Map<String, dynamic>>.from(list);
      }

      if (results[1].statusCode == 200) {
        final data = results[1].data;
        final list = data is Map && data['data'] != null ? data['data'] : data;
        _babyVaccinations = List<Map<String, dynamic>>.from(list);
      }

      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('Error loading vaccinations: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _isVaccinationDone(String vaccineName) {
    return _babyVaccinations.any((v) => v['vaccine_name'] == vaccineName);
  }

  Future<void> _markVaccination(Map<String, dynamic> vaccine) async {
    final provider = context.read<UserStageProvider>();
    final babyId = provider.selectedBabyId;
    if (babyId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Mark ${vaccine['name']} as done?'),
        content: const Text('This will record the vaccination for your baby.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Mark Done'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final response = await ApiService().post(
        '/baby/$babyId/vaccination',
        body: {
          'vaccine_name': vaccine['name'],
          'date_given': DateTime.now().toIso8601String(),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${vaccine['name']} marked as complete!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error marking vaccination: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Vaccination Schedule',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Consumer<UserStageProvider>(
        builder: (context, provider, _) {
          if (provider.selectedBaby == null) {
            return _buildNoBabyState();
          }

          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Baby info
                  _buildBabyCard(provider.selectedBaby!),
                  const SizedBox(height: 16),

                  // Progress
                  _buildProgressCard(),
                  const SizedBox(height: 20),

                  // Vaccine list
                  const Text(
                    'Recommended Vaccines',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  if (_allVaccines.isEmpty)
                    _buildEmptyState()
                  else
                    ..._allVaccines.map(_buildVaccineCard),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBabyCard(Map<String, dynamic> baby) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade300, Colors.red.shade100],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Text('💉', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${baby['name'] ?? 'Baby'}'s Vaccinations",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Keep your baby protected',
                  style: TextStyle(color: Colors.white.withOpacity(0.9)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    final completed = _babyVaccinations.length;
    final total = _allVaccines.length;
    final progress = total > 0 ? completed / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progress',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '$completed / $total',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation(Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVaccineCard(Map<String, dynamic> vaccine) {
    final isDone = _isVaccinationDone(vaccine['name'] ?? '');
    final diseaseProtection = vaccine['disease_protection'] as List<dynamic>?;
    final numberOfDoses = vaccine['number_of_doses'] as int? ?? 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDone ? Colors.green : Colors.grey.shade200,
          width: isDone ? 2 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDone
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isDone ? Iconsax.tick_circle : Iconsax.health,
              color: isDone ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vaccine['name'] ?? 'Vaccine',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                if (vaccine['recommended_age'] != null)
                  Text(
                    'At ${vaccine['recommended_age']}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                if (numberOfDoses > 1)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      '$numberOfDoses doses required',
                      style: TextStyle(color: Colors.orange[700], fontSize: 11),
                    ),
                  ),
                if (diseaseProtection != null && diseaseProtection.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: diseaseProtection.take(3).map((disease) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            disease.toString(),
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.blue[700],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
          if (!isDone)
            IconButton(
              icon: const Icon(Iconsax.add_circle, color: Colors.green),
              onPressed: () => _markVaccination(vaccine),
            )
          else
            const Icon(Iconsax.tick_circle, color: Colors.green),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Iconsax.health, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            'No vaccine schedule available',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildNoBabyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.happyemoji, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No baby profile found',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
