import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final String contactEmail = 'support@maternalhealth.com';
  final String contactPhone = '+1 (555) 123-4567';

  final List<FAQItem> faqs = [
    FAQItem(
      question: 'How do I track my weight during pregnancy?',
      answer:
          'You can log your weight in the Weight Logs section under Health & Tracking. Simply tap "Weight Logs", then click the add button to record your weight. Tracking your weight helps you and your healthcare provider monitor your pregnancy progress.',
      category: 'Tracking',
    ),
    FAQItem(
      question: 'What are normal weight gain ranges for pregnancy?',
      answer:
          'Normal weight gain during pregnancy depends on your pre-pregnancy BMI. Generally, women gain between 25-35 pounds (11-16 kg). Your healthcare provider will give you personalized guidance based on your health profile.',
      category: 'Health',
    ),
    FAQItem(
      question: 'How do I log my checkup records?',
      answer:
          'Visit the Checkup Records section in Health & Tracking. Tap the add button and enter details about your checkup including date, weight, blood pressure, and any notes from your healthcare provider.',
      category: 'Tracking',
    ),
    FAQItem(
      question: 'What should I do if I experience severe symptoms?',
      answer:
          'If you experience severe symptoms like heavy bleeding, severe pain, or difficulty breathing, please seek immediate medical attention. Call emergency services or visit your nearest hospital right away.',
      category: 'Emergency',
    ),
    FAQItem(
      question: 'How do I add emergency contacts?',
      answer:
          'Go to the Care tab and navigate to Emergency Contacts. You can add multiple contacts with their phone numbers. These contacts will be easily accessible in case of emergencies.',
      category: 'Emergency',
    ),
    FAQItem(
      question: 'Can I export my health records?',
      answer:
          'You can take screenshots of your health records or contact our support team for assistance in exporting your data in other formats.',
      category: 'Account',
    ),
    FAQItem(
      question: 'How often should I log my symptoms?',
      answer:
          'You can log symptoms whenever you experience them. However, it\'s helpful to do a daily check-in to maintain a comprehensive health record for your healthcare provider.',
      category: 'Tracking',
    ),
    FAQItem(
      question: 'What does the Kick Counter do?',
      answer:
          'The Kick Counter helps you monitor your baby\'s movements. A healthy kick count is usually 10 movements in a 2-hour period. If you notice a significant decrease in movement, contact your healthcare provider.',
      category: 'Tracking',
    ),
    FAQItem(
      question: 'Is my health data secure and private?',
      answer:
          'Yes, your health data is encrypted and protected with industry-standard security measures. We comply with privacy regulations to ensure your data is kept confidential.',
      category: 'Privacy',
    ),
    FAQItem(
      question: 'How can I update my profile information?',
      answer:
          'You can edit your profile by going to the Profile section and tapping "Edit Profile". Update your information and save the changes.',
      category: 'Account',
    ),
  ];

  late List<FAQItem> filteredFaqs;
  String selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    filteredFaqs = faqs;
  }

  void _filterByCategory(String category) {
    setState(() {
      selectedCategory = category;
      if (category == 'All') {
        filteredFaqs = faqs;
      } else {
        filteredFaqs = faqs.where((faq) => faq.category == category).toList();
      }
    });
  }

  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: contactEmail,
      queryParameters: {
        'subject': 'Help Request - Maternal Health App',
      },
    );

    try {
      await launchUrl(emailLaunchUri);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not launch email: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _launchPhone() async {
    final Uri phoneLaunchUri = Uri(
      scheme: 'tel',
      path: contactPhone,
    );

    try {
      await launchUrl(phoneLaunchUri);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not launch phone: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['All', 'Tracking', 'Health', 'Emergency', 'Account', 'Privacy'];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Help Center',
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
        child: Column(
          children: [
            // Contact Us Section
            _buildContactSection(),
            const SizedBox(height: 24),

            // Category Filter
            _buildCategoryFilter(categories),
            const SizedBox(height: 24),

            // FAQ Section
            _buildFAQSection(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
      child: Column(
        children: [
          // Contact Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Iconsax.message_question,
                  color: Colors.teal,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Need Help?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Get in touch with our support team',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Contact Options
          _buildContactOption(
            icon: Iconsax.sms,
            title: 'Email Us',
            subtitle: contactEmail,
            color: Colors.blue,
            onTap: _launchEmail,
          ),
          const SizedBox(height: 12),
          _buildContactOption(
            icon: Iconsax.call,
            title: 'Call Us',
            subtitle: contactPhone,
            color: Colors.green,
            onTap: _launchPhone,
          ),
          const SizedBox(height: 12),
          _buildContactOption(
            icon: Iconsax.clock,
            title: 'Support Hours',
            subtitle: 'Mon - Fri, 9:00 AM - 6:00 PM (EST)',
            color: Colors.purple,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildContactOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!, width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Iconsax.arrow_right_3, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(List<String> categories) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Browse by Category',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = category == selectedCategory;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (_) => _filterByCategory(category),
                    backgroundColor: Colors.white,
                    selectedColor: Colors.teal.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.teal : Colors.grey[700],
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                    side: BorderSide(
                      color:
                          isSelected ? Colors.teal : Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Frequently Asked Questions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          filteredFaqs.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Column(
                      children: [
                        Icon(
                          Iconsax.search_normal,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No FAQs found',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredFaqs.length,
                  itemBuilder: (context, index) {
                    return FAQTile(
                      faqItem: filteredFaqs[index],
                    );
                  },
                ),
        ],
      ),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;
  final String category;

  FAQItem({
    required this.question,
    required this.answer,
    required this.category,
  });
}

class FAQTile extends StatefulWidget {
  final FAQItem faqItem;

  const FAQTile({
    required this.faqItem,
    super.key,
  });

  @override
  State<FAQTile> createState() => _FAQTileState();
}

class _FAQTileState extends State<FAQTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _isExpanded ? Colors.teal.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isExpanded ? Colors.teal.withOpacity(0.3) : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          onExpansionChanged: (expanded) {
            setState(() => _isExpanded = expanded);
          },
          title: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.faqItem.question,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        widget.faqItem.category,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          trailing: Icon(
            _isExpanded ? Iconsax.arrow_up : Iconsax.arrow_down,
            color: Colors.teal,
            size: 20,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text(
                    widget.faqItem.answer,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
