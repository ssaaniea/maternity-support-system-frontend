import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

class _TrackingScreenState extends State<TrackingScreen> {
  bool _isLoading = true;
  bool _hasProfile = false;

  // Profile data
  String _status = "pregnant"; // "pregnant" or "delivered"
  int? _pregnancyWeek;
  String? _name;
  DateTime? _expectedDeliveryDate;
  DateTime? _actualDeliveryDate;

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
        setState(() {
          _hasProfile = true;
          _name = profile['name'];
          _status = profile['status'] ?? "pregnant";
          _pregnancyWeek = data['pregnancy_week'];
          if (profile['expected_delivery_date'] != null) {
            _expectedDeliveryDate = DateTime.tryParse(
              profile['expected_delivery_date'],
            );
          }
          if (profile['actual_delivery_date'] != null) {
            _actualDeliveryDate = DateTime.tryParse(
              profile['actual_delivery_date'],
            );
          }
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

  int _getBabyAgeWeeks() {
    if (_actualDeliveryDate == null) return 0;
    final now = DateTime.now();
    return now.difference(_actualDeliveryDate!).inDays ~/ 7;
  }

  String _getTitle() {
    return _status == "pregnant"
        ? "Track Your Pregnancy"
        : "Track Your Recovery";
  }

  String _getSubtitle() {
    if (_status == "pregnant" && _pregnancyWeek != null) {
      final weeksLeft = 40 - _pregnancyWeek!;
      return "Week $_pregnancyWeek • $weeksLeft weeks to go";
    } else if (_status == "delivered") {
      final weeks = _getBabyAgeWeeks();
      return "Baby is $weeks week${weeks == 1 ? '' : 's'} old 👶";
    }
    return "";
  }

  List<Widget> _buildTrackingCards() {
    if (_status == "pregnant") {
      return [
        _buildTrackCard(
          icon: Icons.monitor_weight_rounded,
          label: "Weight",
          subLabel: "Track your weight",
          color: const Color(0xFFE0F7FA),
          iconColor: Colors.teal,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WeightScreen()),
          ),
        ),
        _buildTrackCard(
          icon: Icons.healing_rounded,
          label: "Symptoms",
          subLabel: "How do you feel?",
          color: const Color(0xFFF3E5F5),
          iconColor: Colors.purple,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SymptomScreen()),
          ),
        ),
        _buildTrackCard(
          icon: Icons.child_care_rounded,
          label: "Kick Counter",
          subLabel: "Track movements",
          color: const Color(0xFFFFF3E0),
          iconColor: Colors.orange,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const KickCountScreen()),
          ),
        ),
        _buildTrackCard(
          icon: Icons.medical_services_rounded,
          label: "Checkups",
          subLabel: "Doctor visits",
          color: const Color(0xFFE8F5E9),
          iconColor: Colors.green,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CheckupScreen()),
          ),
        ),
      ];
    } else {
      // DELIVERED status
      return [
        _buildTrackCard(
          icon: Icons.monitor_weight_rounded,
          label: "Weight",
          subLabel: "Track recovery",
          color: const Color(0xFFE0F7FA),
          iconColor: Colors.teal,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WeightScreen()),
          ),
        ),
        _buildTrackCard(
          icon: Icons.favorite_rounded,
          label: "Recovery",
          subLabel: "Track healing",
          color: const Color(0xFFFFEBEE),
          iconColor: Colors.red,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RecoveryScreen()),
          ),
        ),
        _buildTrackCard(
          icon: Icons.mood_rounded,
          label: "Mood",
          subLabel: "How are you?",
          color: const Color(0xFFF3E5F5),
          iconColor: Colors.purple,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SymptomScreen()),
          ),
        ),
        _buildTrackCard(
          icon: Icons.medical_services_rounded,
          label: "Checkups",
          subLabel: "Postnatal visits",
          color: const Color(0xFFE8F5E9),
          iconColor: Colors.green,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CheckupScreen()),
          ),
        ),
      ];
    }
  }

  String _getTipForWeek() {
    if (_status == "pregnant") {
      final week = _pregnancyWeek ?? 0;
      if (week < 12) {
        return "💡 First trimester: Take prenatal vitamins and get plenty of rest.";
      } else if (week < 24) {
        return "💡 Second trimester: Your baby can hear you now! Try talking or singing.";
      } else if (week < 36) {
        return "💡 Third trimester: Start preparing your hospital bag and birth plan.";
      } else {
        return "💡 Almost there! Practice breathing exercises and stay relaxed.";
      }
    } else {
      final weeks = _getBabyAgeWeeks();
      if (weeks < 2) {
        return "💡 Rest as much as possible. Your body is healing from delivery.";
      } else if (weeks < 6) {
        return "💡 Postnatal checkups are important. Don't skip your appointments.";
      } else {
        return "💡 Gentle exercises can help recovery. Consult your doctor first.";
      }
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          _getTitle(),
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: _fetchProfile,
            tooltip: "Refresh",
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isPregnant
                ? [const Color(0xFFFFF1EB), const Color(0xFFACE0F9)]
                : [const Color(0xFFFCE4EC), const Color(0xFFE1BEE7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status indicator
                _buildStatusHeader(),
                const SizedBox(height: 24),

                // Section Title
                Text(
                  isPregnant ? "Pregnancy Tracking" : "Recovery Tracking",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 16),

                // Tracking Cards Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.0,
                  children: _buildTrackingCards(),
                ),

                const SizedBox(height: 24),

                // Tips Section
                _buildTipsCard(),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusHeader() {
    final subtitle = _getSubtitle();
    final isPregnant = _status == "pregnant";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isPregnant ? Colors.pink.shade50 : Colors.purple.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPregnant ? Icons.pregnant_woman : Icons.child_friendly,
              size: 32,
              color: isPregnant ? Colors.pink : Colors.purple,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _name != null ? "Hi, $_name!" : "Welcome!",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Progress indicator for pregnant
          if (isPregnant && _pregnancyWeek != null)
            SizedBox(
              width: 50,
              height: 50,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: _pregnancyWeek! / 40,
                    strokeWidth: 6,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation(Colors.pink),
                  ),
                  Center(
                    child: Text(
                      "$_pregnancyWeek",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTipsCard() {
    final isPregnant = _status == "pregnant";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPregnant ? Colors.amber.shade50 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPregnant ? Colors.amber.shade200 : Colors.blue.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: isPregnant ? Colors.amber.shade700 : Colors.blue.shade700,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPregnant ? "Weekly Tip" : "Recovery Tip",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isPregnant
                        ? Colors.amber.shade800
                        : Colors.blue.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getTipForWeek(),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackCard({
    required IconData icon,
    required String label,
    required String subLabel,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 32, color: iconColor),
                ),
                const SizedBox(height: 16),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subLabel,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
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
                Icons.account_circle_outlined,
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
                "Please complete your profile to start tracking your journey.",
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
              const SizedBox(height: 12),
              TextButton(
                onPressed: _fetchProfile,
                child: const Text("Retry Check"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
