import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _soundEnabled = true;
  String _language = 'English';

  static const _primaryTeal = Color(0xFF009688);
  static const _lightTeal = Color(0xFFE0F2F1);

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _emailNotifications = prefs.getBool('email_notifications') ?? true;
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
      _language = prefs.getString('language') ?? 'English';
    });
  }

  Future<void> _savePreference(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Preferences',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: _primaryTeal,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNotificationSection(),
            const SizedBox(height: 20),
            _buildAppearanceSection(),
            const SizedBox(height: 20),
            _buildLanguageSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection() {
    return _buildSection(
      title: 'Notifications',
      icon: Iconsax.notification,
      children: [
        _buildSwitchTile(
          title: 'Push Notifications',
          subtitle: 'Receive booking and update alerts',
          value: _notificationsEnabled,
          onChanged: (value) {
            setState(() => _notificationsEnabled = value);
            _savePreference('notifications_enabled', value);
          },
        ),
        const Divider(height: 1),
        _buildSwitchTile(
          title: 'Email Notifications',
          subtitle: 'Receive updates via email',
          value: _emailNotifications,
          onChanged: (value) {
            setState(() => _emailNotifications = value);
            _savePreference('email_notifications', value);
          },
        ),
      ],
    );
  }

  Widget _buildAppearanceSection() {
    return _buildSection(
      title: 'App Settings',
      icon: Iconsax.setting_2,
      children: [
        _buildSwitchTile(
          title: 'Sound Effects',
          subtitle: 'Play sounds for notifications',
          value: _soundEnabled,
          onChanged: (value) {
            setState(() => _soundEnabled = value);
            _savePreference('sound_enabled', value);
          },
        ),
      ],
    );
  }

  Widget _buildLanguageSection() {
    return _buildSection(
      title: 'Language',
      icon: Iconsax.global,
      children: [
        _buildLanguageTile(),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _lightTeal,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: _primaryTeal),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[500],
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: _primaryTeal,
      ),
    );
  }

  Widget _buildLanguageTile() {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
      title: const Text(
        'Language',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        _language,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[500],
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.grey[400],
      ),
      onTap: () => _showLanguageDialog(),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('English'),
            _buildLanguageOption('Hindi'),
            _buildLanguageOption('Malayalam'),
            _buildLanguageOption('Tamil'),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String language) {
    final isSelected = _language == language;
    return ListTile(
      title: Text(language),
      trailing: isSelected
          ? const Icon(Icons.check, color: _primaryTeal)
          : null,
      onTap: () {
        setState(() => _language = language);
        _savePreference('language', language);
        Navigator.pop(context);
      },
    );
  }
}
