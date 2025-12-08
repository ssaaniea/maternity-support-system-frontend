import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax/iconsax.dart';
import 'package:project_frontend/constants.dart';
import 'package:project_frontend/widgets/tracking_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class CareScreen extends StatefulWidget {
  const CareScreen({super.key});

  @override
  State<CareScreen> createState() => _CareScreenState();
}

class _CareScreenState extends State<CareScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _emergencyContacts = [];
  List<Map<String, dynamic>> _caregivers = [];
  List<Map<String, dynamic>> _myBookings = [];

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

      // Fetch emergency contacts
      final contactsRes = await http.get(
        Uri.parse('$kBaseRoute/mother/me/emergency-contacts'),
        headers: headers,
      );
      if (contactsRes.statusCode == 200) {
        final data = jsonDecode(contactsRes.body);
        _emergencyContacts =
            List<Map<String, dynamic>>.from(data['data'] ?? []);
      }

      // Fetch caregivers
      final caregiversRes = await http.get(
        Uri.parse('$kBaseRoute/caregiver/all'),
        headers: headers,
      );
      if (caregiversRes.statusCode == 200) {
        final data = jsonDecode(caregiversRes.body);
        _caregivers = List<Map<String, dynamic>>.from(data['data'] ?? []);
      }

      // Fetch my bookings
      final bookingsRes = await http.get(
        Uri.parse('$kBaseRoute/caregiver-booking/my-bookings'),
        headers: headers,
      );
      if (bookingsRes.statusCode == 200) {
        final data = jsonDecode(bookingsRes.body);
        _myBookings = List<Map<String, dynamic>>.from(data['data'] ?? []);
      }

      setState(() => _isLoading = false);
    } catch (e) {
      print("Error fetching care data: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _callContact(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not make call')),
      );
    }
  }

  Future<void> _addEmergencyContact(
      String name, String phone, String relation) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("jwt_token");
      if (token == null) return;

      final response = await http.post(
        Uri.parse('$kBaseRoute/mother/me/emergency-contacts'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "name": name,
          "phone": phone,
          "relation": relation,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Iconsax.tick_circle, color: Colors.white),
                SizedBox(width: 8),
                Text("Contact added successfully!"),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        _fetchData();
      }
    } catch (e) {
      print("Error adding contact: $e");
    }
  }

  Future<void> _deleteEmergencyContact(String contactId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("jwt_token");
      if (token == null) return;

      final response = await http.delete(
        Uri.parse('$kBaseRoute/mother/me/emergency-contacts/$contactId'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Contact removed")),
        );
        _fetchData();
      }
    } catch (e) {
      print("Error deleting contact: $e");
    }
  }

  void _showAddContactDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    String selectedRelation = "spouse";

    final relations = [
      {"name": "spouse", "icon": "💑"},
      {"name": "mother", "icon": "👩"},
      {"name": "father", "icon": "👨"},
      {"name": "sibling", "icon": "👫"},
      {"name": "friend", "icon": "🧑‍🤝‍🧑"},
      {"name": "doctor", "icon": "👨‍⚕️"},
      {"name": "other", "icon": "👤"},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child:
                          const Icon(Iconsax.user_add, color: Colors.red, size: 24),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        "Add Emergency Contact",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Iconsax.close_circle),
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
              Divider(color: Colors.grey[200], height: 1),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TrackingTextField(
                        controller: nameController,
                        label: "Name",
                        icon: Iconsax.user,
                        hint: "e.g., John Doe",
                      ),
                      TrackingTextField(
                        controller: phoneController,
                        label: "Phone Number",
                        icon: Iconsax.call,
                        hint: "e.g., +1234567890",
                        keyboardType: TextInputType.phone,
                      ),
                      const TrackingSectionHeader(
                        title: "Relationship",
                        icon: Iconsax.people,
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: relations.map((r) {
                          final isSelected = selectedRelation == r['name'];
                          return GestureDetector(
                            onTap: () {
                              setModalState(() => selectedRelation = r['name']!);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.red.withOpacity(0.15)
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color:
                                      isSelected ? Colors.red : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(r['icon']!,
                                      style: const TextStyle(fontSize: 18)),
                                  const SizedBox(width: 6),
                                  Text(
                                    r['name']!.toUpperCase(),
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.red
                                          : Colors.grey[600],
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (nameController.text.isEmpty ||
                          phoneController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Please fill in all fields")),
                        );
                        return;
                      }
                      _addEmergencyContact(
                        nameController.text,
                        phoneController.text,
                        selectedRelation,
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Add Contact",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Care",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh),
            onPressed: _fetchData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SOS Section
              _buildSOSSection(),
              const SizedBox(height: 24),

              // Emergency Contacts
              _buildEmergencyContactsSection(),
              const SizedBox(height: 24),

              // Find Caregivers
              _buildCaregiversSection(),
              const SizedBox(height: 24),

              // My Bookings
              if (_myBookings.isNotEmpty) _buildBookingsSection(),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSOSSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF5252), Color(0xFFFF1744)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Iconsax.danger, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Emergency SOS",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "Tap to call your emergency contacts",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_emergencyContacts.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Call first contact
                  _callContact(_emergencyContacts.first['phone'] ?? '');
                },
                icon: const Icon(Iconsax.call),
                label: Text(
                  "Call ${_emergencyContacts.first['name']}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmergencyContactsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              "Emergency Contacts",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _showAddContactDialog,
              icon: const Icon(Iconsax.add, size: 18),
              label: const Text("Add"),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_emergencyContacts.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(Iconsax.user_add, size: 48, color: Colors.grey[300]),
                const SizedBox(height: 12),
                Text(
                  "No emergency contacts",
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  "Add contacts for quick SOS access",
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          )
        else
          ...List.generate(
            _emergencyContacts.length,
            (index) => _buildContactCard(_emergencyContacts[index]),
          ),
      ],
    );
  }

  Widget _buildContactCard(Map<String, dynamic> contact) {
    final relationEmojis = {
      'spouse': '💑',
      'mother': '👩',
      'father': '👨',
      'sibling': '👫',
      'friend': '🧑‍🤝‍🧑',
      'doctor': '👨‍⚕️',
      'other': '👤',
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                relationEmojis[contact['relation']] ?? '👤',
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact['name'] ?? 'Unknown',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "${contact['relation']?.toString().toUpperCase() ?? ''} • ${contact['phone']}",
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _callContact(contact['phone'] ?? ''),
            icon: const Icon(Iconsax.call, color: Colors.green),
          ),
          IconButton(
            onPressed: () => _deleteEmergencyContact(contact['_id']),
            icon: Icon(Iconsax.trash, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildCaregiversSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              "Find Caregivers",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                // TODO: Navigate to full caregiver list
              },
              child: const Text("See All"),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_caregivers.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(Iconsax.people, size: 48, color: Colors.grey[300]),
                const SizedBox(height: 12),
                Text(
                  "No caregivers available",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _caregivers.length > 5 ? 5 : _caregivers.length,
              itemBuilder: (context, index) {
                return _buildCaregiverCard(_caregivers[index]);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildCaregiverCard(Map<String, dynamic> caregiver) {
    final shiftColors = {
      'day': Colors.orange,
      'night': Colors.indigo,
      'wholeday': Colors.green,
    };

    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.purple.shade100,
                child: Text(
                  (caregiver['name'] ?? 'U')[0].toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (shiftColors[caregiver['shift']] ?? Colors.grey)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  caregiver['shift']?.toString().toUpperCase() ?? '',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: shiftColors[caregiver['shift']] ?? Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            caregiver['name'] ?? 'Unknown',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            "${caregiver['experience_years'] ?? 0} yrs exp",
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              const Icon(Iconsax.star1, size: 14, color: Colors.amber),
              const SizedBox(width: 4),
              Text(
                "${(caregiver['rating'] ?? 0).toStringAsFixed(1)}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Text(
                "₹${caregiver['amount'] ?? 0}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "My Bookings",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(
          _myBookings.length > 3 ? 3 : _myBookings.length,
          (index) => _buildBookingCard(_myBookings[index]),
        ),
      ],
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final statusColors = {
      'pending': Colors.orange,
      'accepted': Colors.blue,
      'completed': Colors.green,
      'cancelled': Colors.red,
      'rejected': Colors.red,
    };

    final caregiver = booking['caregiver'] as Map<String, dynamic>? ?? {};

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.purple.shade100,
            child: Text(
              (caregiver['name'] ?? 'U')[0].toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  caregiver['name'] ?? 'Caregiver',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  booking['shift']?.toString().toUpperCase() ?? '',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: (statusColors[booking['status']] ?? Colors.grey)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              booking['status']?.toString().toUpperCase() ?? '',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: statusColors[booking['status']] ?? Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
