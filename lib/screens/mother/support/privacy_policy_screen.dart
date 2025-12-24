import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Privacy Policy',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Last Updated
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Iconsax.calendar, color: Colors.blue, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Last updated: December 24, 2025',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _buildSection(
                title: '1. Introduction',
                content:
                    'Welcome to Maternal Health App ("we", "us", "our", or "Company"). We are committed to protecting your privacy. This Privacy Policy explains our online information practices and the choices you can make about the way your information is collected and used.',
              ),

              _buildSection(
                title: '2. Information We Collect',
                content:
                    'We collect information you provide directly to us, such as:\n\n• Personal information (name, email, phone number, date of birth)\n• Medical information (pregnancy status, weight, health conditions)\n• Emergency contact details\n• Health tracking data (weight logs, checkup records, symptoms)\n• Device information (device type, operating system)\n• Usage data (features used, time spent in app)',
              ),

              _buildSection(
                title: '3. How We Use Your Information',
                content:
                    'We use the information we collect to:\n\n• Provide and improve our services\n• Track your health progress and provide personalized recommendations\n• Send important health reminders and notifications\n• Communicate with you about updates, support, and legal changes\n• Comply with legal obligations\n• Ensure the security of our application',
              ),

              _buildSection(
                title: '4. Data Security',
                content:
                    'We implement industry-standard security measures including:\n\n• End-to-end encryption for sensitive health data\n• Secure authentication protocols\n• Regular security audits and updates\n• Restricted access to user data\n• Compliance with HIPAA and data protection regulations\n\nHowever, no method of transmission over the internet is 100% secure.',
              ),

              _buildSection(
                title: '5. Data Sharing',
                content:
                    'We do not sell, trade, or rent your personal information to third parties. We may share your information only when:\n\n• Required by law or government authorities\n• Necessary to protect your health and safety\n• With your explicit consent\n• With healthcare providers if you authorize it\n• With service providers who assist us in operating our services',
              ),

              _buildSection(
                title: '6. Your Privacy Rights',
                content:
                    'You have the right to:\n\n• Access your personal data\n• Request correction of inaccurate data\n• Request deletion of your data\n• Withdraw consent at any time\n• Export your health records\n• Opt-out of marketing communications\n\nTo exercise these rights, contact us at support@maternalhealth.com',
              ),

              _buildSection(
                title: '7. Cookies and Tracking',
                content:
                    'Our app may use cookies and similar tracking technologies to:\n\n• Remember your preferences\n• Understand how you use our app\n• Improve user experience\n• Provide personalized content\n\nYou can control cookie settings through your device settings.',
              ),

              _buildSection(
                title: '8. Third-Party Services',
                content:
                    'Our app may contain links to third-party services. We are not responsible for their privacy practices. Please review their privacy policies before providing any information.',
              ),

              _buildSection(
                title: '9. Children\'s Privacy',
                content:
                    'Our services are not intended for children under 13. We do not knowingly collect personal information from children under 13. If we discover we have collected such information, we will delete it promptly.',
              ),

              _buildSection(
                title: '10. Policy Updates',
                content:
                    'We may update this Privacy Policy from time to time. We will notify you of significant changes via email or through the app. Your continued use of the app indicates your acceptance of the updated policy.',
              ),

              _buildSection(
                title: '11. Contact Us',
                content:
                    'If you have any questions about this Privacy Policy, please contact us at:\n\nEmail: support@maternalhealth.com\nPhone: +1 (555) 123-4567\n\nWe will respond to your inquiry within 30 days.',
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey[200]!,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            content,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
