import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class TermsOfServiceScreen extends StatefulWidget {
  const TermsOfServiceScreen({super.key});

  @override
  State<TermsOfServiceScreen> createState() => _TermsOfServiceScreenState();
}

class _TermsOfServiceScreenState extends State<TermsOfServiceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Terms of Service',
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
                  color: Colors.cyan.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.cyan.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Iconsax.calendar, color: Colors.cyan, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Last updated: December 24, 2025',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.cyan[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _buildSection(
                title: '1. Acceptance of Terms',
                content:
                    'By accessing and using the Maternal Health App ("App"), you accept and agree to be bound by the terms and provision of this agreement. If you do not agree to abide by the above, please do not use this service.',
              ),

              _buildSection(
                title: '2. License to Use',
                content:
                    'We grant you a limited, non-exclusive, revocable license to use this App for personal, non-commercial purposes only. You may not:\n\n• Reproduce, modify, or distribute the App\n• Reverse engineer or decompile the code\n• Use the App for commercial purposes\n• Attempt to gain unauthorized access\n• Harass, abuse, or harm others through the App',
              ),

              _buildSection(
                title: '3. User Responsibilities',
                content:
                    'You agree to:\n\n• Provide accurate and complete information\n• Maintain the confidentiality of your account credentials\n• Use the App in compliance with all applicable laws\n• Not engage in any prohibited conduct\n• Take responsibility for all activities under your account\n• Promptly notify us of any unauthorized access',
              ),

              _buildSection(
                title: '4. Medical Disclaimer',
                content:
                    'This App is designed to help track your health and provide educational information. It is NOT a substitute for professional medical advice. You should:\n\n• Consult with your healthcare provider before making medical decisions\n• Seek immediate medical attention for emergencies\n• Not rely solely on this App for medical diagnosis\n• Report all health concerns to your doctor\n• Keep your healthcare provider informed of your health tracking',
              ),

              _buildSection(
                title: '5. Intellectual Property Rights',
                content:
                    'The App and its content, including but not limited to text, graphics, logos, images, and software, are the property of Maternal Health Company or its content suppliers and are protected by international copyright laws. You may not reproduce or distribute any content without permission.',
              ),

              _buildSection(
                title: '6. Limitation of Liability',
                content:
                    'To the fullest extent permitted by law, we shall not be liable for:\n\n• Indirect, incidental, or consequential damages\n• Loss of data or medical information\n• Interruption of service\n• Third-party content or links\n• Any damages arising from use of the App\n\nOur total liability shall not exceed the amount paid by you, if any.',
              ),

              _buildSection(
                title: '7. Warranty Disclaimer',
                content:
                    'The App is provided "AS IS" without warranties of any kind. We do not warrant that:\n\n• The App will be uninterrupted or error-free\n• Results will meet your expectations\n• The App is suitable for your purposes\n• All features will function correctly\n\nUse the App at your own risk.',
              ),

              _buildSection(
                title: '8. Termination',
                content:
                    'We reserve the right to terminate or suspend your account and access to the App at any time without notice if:\n\n• You violate these terms\n• You engage in harmful or illegal activities\n• You abuse the platform or other users\n• We cease operations\n\nTermination does not relieve you of obligations incurred before termination.',
              ),

              _buildSection(
                title: '9. Data and Account Deletion',
                content:
                    'You may request deletion of your account and associated data at any time. Upon deletion:\n\n• Your personal information will be removed from our active database\n• We may retain data required by law or for backup purposes\n• You will lose access to all your health records and tracked data\n• The deletion process may take up to 30 days',
              ),

              _buildSection(
                title: '10. Third-Party Links',
                content:
                    'The App may contain links to third-party websites and services. We are not responsible for:\n\n• The content of external sites\n• The policies of external services\n• Your interactions with third parties\n• Any damages from using third-party services\n\nPlease review their terms and policies before use.',
              ),

              _buildSection(
                title: '11. User-Generated Content',
                content:
                    'Any health information, notes, or data you input into the App is user-generated content. By using the App, you grant us permission to store, process, and protect this information. We will not use your health data for marketing without explicit consent.',
              ),

              _buildSection(
                title: '12. Emergency Services',
                content:
                    'If you experience a medical emergency:\n\n• Do NOT rely on the App to notify emergency services\n• Call emergency services directly (911 in the US)\n• Use the app\'s emergency contact feature only as a supplement\n• Always seek immediate professional medical help\n\nSave emergency contacts in your device contacts for quick access.',
              ),

              _buildSection(
                title: '13. Changes to Terms',
                content:
                    'We reserve the right to modify these terms at any time. Changes will be effective immediately upon posting to the App. Continued use of the App indicates your acceptance of modified terms. We encourage you to review these terms regularly.',
              ),

              _buildSection(
                title: '14. Governing Law',
                content:
                    'These terms are governed by and construed in accordance with the laws of the jurisdiction where Maternal Health Company is located. You agree to submit to the exclusive jurisdiction of the courts in that location.',
              ),

              _buildSection(
                title: '15. Contact Information',
                content:
                    'For questions about these Terms of Service, please contact us at:\n\nEmail: support@maternalhealth.com\nPhone: +1 (555) 123-4567\n\nWe will respond to your inquiry within 30 days.',
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
