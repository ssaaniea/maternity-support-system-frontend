// services/mother_service.dart
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:project_frontend/apiService.dart';
import 'package:project_frontend/screens/mother/mother_app_shell.dart';
import 'package:project_frontend/screens/mother/tracking/checkup_screen.dart';
import 'package:project_frontend/screens/mother/tracking/kick_count_screen.dart';
import 'package:project_frontend/screens/mother/tracking/symptom_screen.dart';
import 'package:project_frontend/screens/mother/tracking/tracking_screen.dart';
import 'package:project_frontend/screens/mother/tracking/weight_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_frontend/constants.dart';
// screens/mother/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:project_frontend/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_frontend/screens/mother/profile/edit_profile_screen.dart';
import 'package:project_frontend/screens/mother/profile/mark_delivery_dialog.dart';
import 'package:project_frontend/screens/mother/baby/baby_dashboard.dart';
import 'package:project_frontend/screens/mother/support/help_center_screen.dart';
import 'package:project_frontend/screens/mother/support/privacy_policy_screen.dart';
import 'package:project_frontend/screens/mother/support/terms_of_service_screen.dart';
import 'package:provider/provider.dart';
import 'package:project_frontend/providers/user_stage_provider.dart';

class MotherService {
  static Future<Map<String, dynamic>?> getProfile() async {
    try {
      final response = await ApiService().get('/mother/me/profile');

      log('Profile Response Status: ${response.statusCode}');
      log('Profile data: ${response.data}');
      if (response.statusCode == 200) {
        final decoded = response.data;
        log('Decoded response: $decoded');
        // Extract the nested data from the response
        if (decoded is Map && decoded.containsKey('data')) {
          final profileData = decoded['data'];
          // Add pregnancy_week from top level if it exists
          if (decoded.containsKey('pregnancy_week')) {
            profileData['pregnancy_week'] = decoded['pregnancy_week'];
          }
          log('Extracted profile data: $profileData');
          return profileData;
        }
        return decoded;
      } else if (response.statusCode == 404) {
        log('Profile not found (404)');
        return null;
      }
      log('Failed to load profile: ${response.statusCode}, ${response.data}');
    } catch (e) {
      log('Error fetching profile: $e');
      rethrow;
    }
    return null;
  }

  static Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await ApiService().put(
        '/mother/me/profile',
        body: data,
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _profileData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    log('Starting to load profile');
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final profile = await MotherService.getProfile();
      log('Profile loaded: $profile');
      if (mounted) {
        setState(() {
          _profileData = profile;
          _isLoading = false;
          log('Profile data set in state: $_profileData');
        });
      }
    } catch (e) {
      log('Error loading profile: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load profile';
          _isLoading = false;
        });
      }
    }
  }

  String _getStatusText() {
    if (_profileData == null) return '';

    final status = _profileData!['status'];
    if (status == 'pregnant') {
      final week = _profileData!['pregnancy_week'];
      return 'Pregnancy • Week ${week ?? '??'}';
    } else if (status == 'delivered') {
      // Calculate days since delivery from actual_delivery_date
      final deliveryDateStr = _profileData!['actual_delivery_date'];
      if (deliveryDateStr != null) {
        final deliveryDate = DateTime.tryParse(deliveryDateStr);
        if (deliveryDate != null) {
          final days = DateTime.now().difference(deliveryDate).inDays;
          return 'Postpartum • Day $days';
        }
      }
      return 'Postpartum';
    }
    return '';
  }

  Color _getStatusColor() {
    if (_profileData == null) return Colors.blue;
    final status = _profileData!['status'];
    return status == 'pregnant' ? Colors.blue : Colors.purple;
  }

  // Mark as delivered
  void _markAsDelivered() {
    showDialog(
      context: context,
      builder: (ctx) => MarkDeliveryDialog(
        onSuccess: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎉 Congratulations on your new baby!'),
              backgroundColor: Colors.pink,
            ),
          );
          _loadProfile(); // Local refresh
          // Global refresh
          if (mounted) {
            context.read<UserStageProvider>().onDeliveryMarked();
          }
        },
      ),
    );
  }

  // Add baby dialog for postpartum users
  void _showAddBabyDialog() {
    final nameController = TextEditingController();
    final weightController = TextEditingController();
    String gender = 'male';
    DateTime birthDate = DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Add Baby'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Baby Name *',
                    prefixIcon: const Icon(Iconsax.user),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setDialogState(() => gender = 'male'),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: gender == 'male'
                                ? Colors.blue.withOpacity(0.1)
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: gender == 'male'
                                  ? Colors.blue
                                  : Colors.transparent,
                            ),
                          ),
                          child: Column(
                            children: [
                              const Text('👦', style: TextStyle(fontSize: 24)),
                              Text(
                                'Boy',
                                style: TextStyle(
                                  fontWeight: gender == 'male'
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setDialogState(() => gender = 'female'),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: gender == 'female'
                                ? Colors.pink.withOpacity(0.1)
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: gender == 'female'
                                  ? Colors.pink
                                  : Colors.transparent,
                            ),
                          ),
                          child: Column(
                            children: [
                              const Text('👧', style: TextStyle(fontSize: 24)),
                              Text(
                                'Girl',
                                style: TextStyle(
                                  fontWeight: gender == 'female'
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: weightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Birth Weight (grams)',
                    prefixIcon: const Icon(Iconsax.weight),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter baby name')),
                  );
                  return;
                }
                Navigator.pop(ctx);
                final response = await ApiService().post(
                  '/baby/create',
                  body: {
                    'name': nameController.text.trim(),
                    'gender': gender,
                    'birth_date': birthDate.toIso8601String(),
                    'birth_weight': int.tryParse(weightController.text) ?? 0,
                  },
                );
                if (response.statusCode == 200 || response.statusCode == 201) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Baby added successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _loadProfile(); // Local refresh
                  // Global refresh
                  if (mounted) {
                    context.read<UserStageProvider>().refreshBabies();
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                foregroundColor: Colors.white,
              ),
              child: const Text('Add Baby'),
            ),
          ],
        ),
      ),
    );
  }

  String _getLatestWeightLog() {
    final weightLogs = _profileData?['weight_logs'];
    log('Weight logs: $weightLogs');
    if (weightLogs is List && weightLogs.isNotEmpty) {
      final latest = weightLogs.last as Map<String, dynamic>;
      final weight = latest['weight_kg']?.toString() ?? 'N/A';
      log('Latest weight: $weight');
      return weight;
    }
    log('No weight logs found');
    return 'N/A';
  }

  String _getLastCheckupDate() {
    final checkupLogs = _profileData?['checkup_logs'];
    log('Checkup logs: $checkupLogs');
    if (checkupLogs is List && checkupLogs.isNotEmpty) {
      final latest = checkupLogs.last as Map<String, dynamic>;
      final dateStr = latest['date'];
      log('Latest checkup date string: $dateStr');
      if (dateStr != null) {
        try {
          final date = DateTime.parse(dateStr.toString());
          final formatted = '${date.day}/${date.month}/${date.year}';
          log('Formatted checkup date: $formatted');
          return formatted;
        } catch (e) {
          log('Error parsing date: $e');
          return 'N/A';
        }
      }
    }
    log('No checkup logs found');
    return 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    final contacts = _profileData?['emergency_contacts'];
    final hasContacts = contacts is List && contacts.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Iconsax.info_circle,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadProfile,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadProfile,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Profile Header
                    _buildProfileHeader(),
                    const SizedBox(height: 16),

                    // Account Section
                    _buildSection(
                      title: "Account",
                      items: [
                        _ProfileMenuItem(
                          icon: Iconsax.user_edit,
                          title: "Edit Profile",
                          subtitle: "Update your personal information",
                          color: Colors.blue,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProfileScreen(
                                  profileData: _profileData ?? {},
                                ),
                              ),
                            ).then((result) {
                              if (result == true) {
                                _loadProfile();
                              }
                            });
                          },
                        ),
                        // _ProfileMenuItem(
                        //   icon: Iconsax.security_safe,
                        //   title: "Security",
                        //   subtitle: "Password and authentication",
                        //   color: Colors.green,
                        //   onTap: () {},
                        // ),
                        // _ProfileMenuItem(
                        //   icon: Iconsax.notification,
                        //   title: "Notifications",
                        //   subtitle: "Manage notification preferences",
                        //   color: Colors.orange,
                        //   onTap: () {},
                        // ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Health & Tracking Section
                    _buildSection(
                      title: "Health & Tracking",
                      items: [
                        _ProfileMenuItem(
                          icon: Iconsax.health,
                          title: "Weight Logs",
                          subtitle:
                              "${_profileData?['weight_logs']?.length ?? 0} entries • Latest: ${_getLatestWeightLog()} kg",
                          color: Colors.red,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WeightScreen(),
                              ),
                            );
                          },
                        ),
                        _ProfileMenuItem(
                          icon: Iconsax.calendar,
                          title: "Checkup Records",
                          subtitle:
                              "${_profileData?['checkup_logs']?.length ?? 0} checkups • Last: ${_getLastCheckupDate()}",
                          color: Colors.purple,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CheckupScreen(),
                              ),
                            );
                          },
                        ),
                        _ProfileMenuItem(
                          icon: Iconsax.heart,
                          title: "Symptoms",
                          subtitle:
                              "${_profileData?['symptom_logs']?.length ?? 0} symptom logs",
                          color: Colors.orange,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SymptomScreen(),
                              ),
                            );
                          },
                        ),
                        if (_profileData?['status'] == 'pregnant')
                          _ProfileMenuItem(
                            icon: Iconsax.activity,
                            title: "Kick Counter",
                            subtitle:
                                "${_profileData?['kick_counts']?.length ?? 0} sessions tracked",
                            color: Colors.pink,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => KickCountScreen(),
                                ),
                              );
                            },
                          ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Baby Section (for postpartum users only)
                    if (_profileData?['status'] == 'delivered')
                      _buildSection(
                        title: "Baby",
                        items: [
                          _ProfileMenuItem(
                            icon: Iconsax.happyemoji,
                            title: "Baby Dashboard",
                            subtitle: "View and manage baby profiles",
                            color: Colors.pink,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const BabyDashboard(),
                                ),
                              ).then((_) => _loadProfile());
                            },
                          ),
                          _ProfileMenuItem(
                            icon: Iconsax.add_circle,
                            title: "Add Baby",
                            subtitle: "Add another baby profile",
                            color: Colors.purple,
                            onTap: () => _showAddBabyDialog(),
                          ),
                        ],
                      ),

                    if (_profileData?['status'] == 'delivered')
                      const SizedBox(height: 16),

                    // Emergency Section
                    _buildSection(
                      title: "Emergency",
                      items: [
                        _ProfileMenuItem(
                          icon: Iconsax.call,
                          title: "Emergency Contacts",
                          subtitle: hasContacts
                              ? "${_profileData!['emergency_contacts'].length} contacts saved"
                              : "No contacts added",
                          color: Colors.red,
                          onTap: () {
                            // Navigate to care tab (index 3)
                            MotherAppShell.switchToTab(context, 3);
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Support Section
                    _buildSection(
                      title: "Support",
                      items: [
                        _ProfileMenuItem(
                          icon: Iconsax.message_question,
                          title: "Help Center",
                          subtitle: "Get help and support",
                          color: Colors.teal,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HelpCenterScreen(),
                              ),
                            );
                          },
                        ),
                        _ProfileMenuItem(
                          icon: Iconsax.shield_tick,
                          title: "Privacy Policy",
                          subtitle: "Learn about your privacy",
                          color: Colors.indigo,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const PrivacyPolicyScreen(),
                              ),
                            );
                          },
                        ),
                        _ProfileMenuItem(
                          icon: Iconsax.document_text,
                          title: "Terms of Service",
                          subtitle: "Read our terms",
                          color: Colors.cyan,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const TermsOfServiceScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Mark as Delivered Button (show only if pregnant)
                    if (_profileData != null &&
                        _profileData!['status'] == 'pregnant')
                      _buildMarkAsDeliveredButton(),

                    if (_profileData != null &&
                        _profileData!['status'] == 'pregnant')
                      const SizedBox(height: 16),

                    // Logout Button
                    _buildLogoutButton(),

                    const SizedBox(height: 32),

                    // App Version
                    Text(
                      "Version 1.0.0",
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    final statusColor = _getStatusColor();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Profile Picture
          Stack(
            children: [
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: statusColor.withOpacity(0.1),
                  border: Border.all(
                    color: statusColor.withOpacity(0.2),
                    width: 3,
                  ),
                  image:
                      _profileData?['profile_picture'] != null &&
                          _profileData!['profile_picture'].isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(_profileData!['profile_picture']),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child:
                    _profileData?['profile_picture'] == null ||
                        _profileData!['profile_picture'].isEmpty
                    ? Icon(
                        Iconsax.user,
                        size: 48,
                        color: statusColor,
                      )
                    : null,
              ),
              // Positioned(
              //   bottom: 0,
              //   right: 0,
              //   child: GestureDetector(
              //     onTap: () {
              //       // Edit profile picture
              //     },
              //     child: Container(
              //       padding: const EdgeInsets.all(6),
              //       decoration: BoxDecoration(
              //         color: statusColor,
              //         shape: BoxShape.circle,
              //         border: Border.all(
              //           color: Colors.white,
              //           width: 2,
              //         ),
              //       ),
              //       child: const Icon(
              //         Iconsax.edit_2,
              //         size: 14,
              //         color: Colors.white,
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _profileData != null
                ? (_profileData!['name'] ?? 'Unknown')
                : 'Loading...',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _profileData?['phone_no'] ?? '',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          if (_profileData != null &&
              (_profileData!['age'] != null ||
                  _profileData!['address'] != null)) ...[
            const SizedBox(height: 8),
            Text(
              [
                if (_profileData!['age'] != null)
                  '${_profileData!['age']} years',
                if (_profileData!['address'] != null) _profileData!['address'],
              ].join(' • '),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
          if (_profileData != null && _getStatusText().isNotEmpty) ...[
            const SizedBox(height: 16),
            // Stage Badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: statusColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _profileData!['status'] == 'pregnant'
                        ? Iconsax.heart
                        : Iconsax.lovely,
                    size: 16,
                    color: statusColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _getStatusText(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<_ProfileMenuItem> items,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isLast = index == items.length - 1;

                return Column(
                  children: [
                    InkWell(
                      onTap: item.onTap,
                      borderRadius: BorderRadius.vertical(
                        top: index == 0
                            ? const Radius.circular(16)
                            : Radius.zero,
                        bottom: isLast
                            ? const Radius.circular(16)
                            : Radius.zero,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: item.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                item.icon,
                                color: item.color,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.subtitle,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Iconsax.arrow_right_3,
                              size: 18,
                              color: Colors.grey[400],
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (!isLast)
                      Divider(
                        height: 1,
                        indent: 62,
                        color: Colors.grey[200],
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarkAsDeliveredButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: _markAsDelivered,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.pink.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Iconsax.happyemoji,
                    color: Colors.pink,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  "Mark as Delivered",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.pink,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Iconsax.arrow_right_3,
                  color: Colors.grey,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: () async {
            final shouldLogout = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: const Text("Logout"),
                content: const Text(
                  "Are you sure you want to logout?",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: const Text("Logout"),
                  ),
                ],
              ),
            );

            if (shouldLogout == true && mounted) {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(),
                  ),
                  (route) => false,
                );
              }
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Iconsax.logout,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  "Logout",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Iconsax.arrow_right_3,
                  size: 18,
                  color: Colors.red,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileMenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}
