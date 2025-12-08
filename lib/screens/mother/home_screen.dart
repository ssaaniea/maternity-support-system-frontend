import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:project_frontend/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;

  // Profile data
  String _name = "Mom";
  String _status = "pregnant";
  int? _pregnancyWeek;
  DateTime? _expectedDeliveryDate;
  DateTime? _actualDeliveryDate;

  // Latest tracking data
  double? _latestWeight;
  int? _symptomCount;
  int? _lastKickCount;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("jwt_token");
      if (token == null) {
        setState(() => _isLoading = false);
        return;
      }

      final headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      };

      // Fetch profile
      final profileRes = await http.get(
        Uri.parse('$kBaseRoute/mother/me/profile'),
        headers: headers,
      );

      if (profileRes.statusCode == 200) {
        final data = jsonDecode(profileRes.body);
        final profile = data['data'];
        setState(() {
          _name = profile['name'] ?? "Mom";
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

          // Get latest weight from weight_logs
          final weightLogs = profile['weight_logs'] as List? ?? [];
          if (weightLogs.isNotEmpty) {
            _latestWeight = (weightLogs.last['weight_kg'] as num?)?.toDouble();
          }

          // Get symptom count from today
          final symptomLogs = profile['symptom_logs'] as List? ?? [];
          if (symptomLogs.isNotEmpty) {
            final lastSymptoms = symptomLogs.last['symptoms'] as List? ?? [];
            _symptomCount = lastSymptoms.length;
          }

          // Get last kick count
          final kickCounts = profile['kick_counts'] as List? ?? [];
          if (kickCounts.isNotEmpty) {
            _lastKickCount = kickCounts.last['kick_count'];
          }
        });
      }

      setState(() => _isLoading = false);
    } catch (e) {
      print("Error fetching home data: $e");
      setState(() => _isLoading = false);
    }
  }

  int _getWeeksRemaining() {
    if (_pregnancyWeek == null) return 0;
    return 40 - _pregnancyWeek!;
  }

  int _getBabyAgeWeeks() {
    if (_actualDeliveryDate == null) return 0;
    return DateTime.now().difference(_actualDeliveryDate!).inDays ~/ 7;
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    return "Good Evening";
  }

  String _getSubtitle() {
    if (_status == "pregnant" && _pregnancyWeek != null) {
      final weeksLeft = _getWeeksRemaining();
      return "In $weeksLeft weeks you're going to meet your baby! 💕";
    } else if (_status == "delivered") {
      final weeks = _getBabyAgeWeeks();
      return "Your baby is $weeks week${weeks == 1 ? '' : 's'} old! 👶";
    }
    return "Welcome to your pregnancy journey";
  }

  // Baby size comparison based on week
  Map<String, String> _getBabySizeInfo() {
    final week = _pregnancyWeek ?? 0;
    if (week <= 8)
      return {"size": "Raspberry", "emoji": "🫐", "length": "1.6cm"};
    if (week <= 12) return {"size": "Lime", "emoji": "🍋", "length": "5.4cm"};
    if (week <= 16)
      return {"size": "Avocado", "emoji": "🥑", "length": "11.6cm"};
    if (week <= 20)
      return {"size": "Banana", "emoji": "🍌", "length": "16.5cm"};
    if (week <= 24) return {"size": "Corn", "emoji": "🌽", "length": "30cm"};
    if (week <= 28)
      return {"size": "Eggplant", "emoji": "🍆", "length": "37.6cm"};
    if (week <= 32)
      return {"size": "Coconut", "emoji": "🥥", "length": "42.4cm"};
    if (week <= 36)
      return {"size": "Honeydew", "emoji": "🍈", "length": "47.4cm"};
    return {"size": "Watermelon", "emoji": "🍉", "length": "51cm"};
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isPregnant = _status == "pregnant";

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          '${_getGreeting()}, $_name',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black54),
            onPressed: _fetchData,
          ),
        ],
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isPregnant
                ? [
                    const Color.fromARGB(255, 158, 204, 200),
                    const Color.fromARGB(255, 226, 223, 222),
                    const Color(0xffeecde6),
                  ]
                : [
                    const Color(0xFFFCE4EC),
                    const Color(0xFFE1BEE7),
                    const Color(0xFFE8EAF6),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _fetchData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subtitle
                  Text(
                    _getSubtitle(),
                    style: const TextStyle(
                      color: Color.fromARGB(255, 103, 109, 103),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Week Progress (only for pregnant)
                  if (isPregnant) ...[
                    _buildWeekProgress(),
                    const SizedBox(height: 16),
                  ],

                  // Main visual card
                  isPregnant
                      ? _buildPregnancyVisual()
                      : _buildPostnatalVisual(),

                  const SizedBox(height: 20),

                  // Tracker cards
                  isPregnant
                      ? _buildPregnancyTracker()
                      : _buildRecoveryTracker(),

                  // const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeekProgress() {
    final week = _pregnancyWeek ?? 0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final widgetWidth = constraints.maxWidth;
        final singleItemWidth = widgetWidth / 41;
        final containerWidth = singleItemWidth / 3;
        final margin = singleItemWidth / 3;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (int i = 1; i <= 40; i++)
              Container(
                width: containerWidth,
                height: i == week ? 40 : 30,
                margin: EdgeInsets.symmetric(horizontal: margin / 2),
                decoration: BoxDecoration(
                  color: i < week
                      ? const Color.fromRGBO(230, 151, 212, 1)
                      : i == week
                      ? const Color.fromARGB(255, 230, 134, 190)
                      : const Color.fromARGB(255, 180, 180, 180),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildPregnancyVisual() {
    final babyInfo = _getBabySizeInfo();

    return Stack(
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.all(40),
            child: Image.asset(
              'assets/images/fetus.jpg',
              width: 180,
              height: 180,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.pink.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.child_care,
                  size: 80,
                  color: Colors.pink.shade200,
                ),
              ),
            ),
          ),
        ),
        // Baby size card
        Positioned(
          top: 20,
          right: 20,
          child: Transform.rotate(
            angle: 15 * pi / 180,
            child: _buildInfoCard(
              icon: babyInfo['emoji']!,
              title: "Size of a",
              value: babyInfo['size']!,
              subtitle: babyInfo['length'],
            ),
          ),
        ),
        // Week indicator
        Positioned(
          bottom: 20,
          left: 20,
          child: Transform.rotate(
            angle: -10 * pi / 180,
            child: _buildInfoCard(
              icon: "📅",
              title: "Week",
              value: "${_pregnancyWeek ?? '-'}",
              subtitle: "of 40",
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPostnatalVisual() {
    final weeks = _getBabyAgeWeeks();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Text("👶", style: TextStyle(fontSize: 40)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Congratulations!",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Your baby is $weeks week${weeks == 1 ? '' : 's'} old",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: Colors.amber,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getPostnatalTip(weeks),
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getPostnatalTip(int weeks) {
    if (weeks < 2)
      return "Rest is essential. Accept help from family and friends.";
    if (weeks < 6) return "Remember to attend your postnatal checkup.";
    if (weeks < 12) return "Gentle walks can help with recovery.";
    return "You're doing amazing! Take care of yourself too.";
  }

  Widget _buildInfoCard({
    required String icon,
    required String title,
    required String value,
    String? subtitle,
  }) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (subtitle != null)
            Text(
              subtitle,
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
        ],
      ),
    );
  }

  Widget _buildPregnancyTracker() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 233, 213, 228),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Your Health",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 100, 80, 95),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTrackerCard(
                  icon: Icons.monitor_weight,
                  title: 'Weight',
                  value: _latestWeight != null
                      ? '${_latestWeight!.toStringAsFixed(1)} kg'
                      : '-',
                  bgColor: const Color(0xffeecde6),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTrackerCard(
                  icon: Icons.child_care,
                  title: 'Last Kicks',
                  value: _lastKickCount != null ? '$_lastKickCount' : '-',
                  bgColor: const Color(0xffeecde6),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTrackerCard(
                  icon: Icons.sick,
                  title: 'Symptoms',
                  value: _symptomCount != null ? '$_symptomCount noted' : '-',
                  bgColor: const Color(0xffeecde6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecoveryTracker() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Your Recovery",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 100, 80, 120),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTrackerCard(
                  icon: Icons.monitor_weight,
                  title: 'Weight',
                  value: _latestWeight != null
                      ? '${_latestWeight!.toStringAsFixed(1)} kg'
                      : '-',
                  bgColor: Colors.purple.shade100,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTrackerCard(
                  icon: Icons.favorite,
                  title: 'Recovery',
                  value: 'Track',
                  bgColor: Colors.purple.shade100,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTrackerCard(
                  icon: Icons.mood,
                  title: 'Mood',
                  value: 'Log',
                  bgColor: Colors.purple.shade100,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrackerCard({
    required IconData icon,
    required String title,
    required String value,
    required Color bgColor,
  }) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: Colors.black87),
          Text(
            title,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
