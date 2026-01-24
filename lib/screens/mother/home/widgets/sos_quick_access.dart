import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:project_frontend/apiService.dart';
import 'package:project_frontend/screens/mother/care/care_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class SOSQuickAccess extends StatefulWidget {
  const SOSQuickAccess({super.key});

  @override
  State<SOSQuickAccess> createState() => _SOSQuickAccessState();
}

class _SOSQuickAccessState extends State<SOSQuickAccess> {
  bool _isLoading = false;

  Future<void> _callEmergency() async {
    setState(() => _isLoading = true);

    try {
      // Fetch emergency contacts
      final response = await ApiService().get('/mother/me/emergency-contacts');

      if (response.success && response.data != null) {
        final contacts = List<Map<String, dynamic>>.from(
          response.data['data'] ?? [],
        );

        if (contacts.isNotEmpty) {
          final phone = contacts.first['phone'] ?? '';
          if (phone.isNotEmpty) {
            final uri = Uri.parse('tel:$phone');
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri);
            } else {
              _showSnackBar('Could not make call');
            }
          } else {
            _showSnackBar('No phone number available');
          }
        } else {
          // No contacts, navigate to care screen to add
          _showSnackBar('No emergency contacts. Add one first.');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CareScreen()),
          );
        }
      } else {
        _showSnackBar('Failed to fetch contacts');
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    }

    if (mounted) setState(() => _isLoading = false);
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isLoading ? null : _callEmergency,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF5252), Color(0xFFFF1744)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Iconsax.call, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Emergency SOS",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Tap to call emergency contact",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Iconsax.call, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
