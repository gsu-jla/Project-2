import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'English';
  String _selectedCurrency = 'USD';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('darkMode') ?? false;
      _notificationsEnabled = prefs.getBool('notifications') ?? true;
      _selectedLanguage = prefs.getString('language') ?? 'English';
      _selectedCurrency = prefs.getString('currency') ?? 'USD';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _isDarkMode);
    await prefs.setBool('notifications', _notificationsEnabled);
    await prefs.setString('language', _selectedLanguage);
    await prefs.setString('currency', _selectedCurrency);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[100],
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.black87),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Dark Mode'),
            subtitle: const Text('Enable dark theme'),
            trailing: Switch(
              value: _isDarkMode,
              onChanged: (value) {
                setState(() {
                  _isDarkMode = value;
                });
                _saveSettings();
              },
              activeColor: Colors.deepPurple,
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            subtitle: const Text('Enable push notifications'),
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
                _saveSettings();
              },
              activeColor: Colors.deepPurple,
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            subtitle: Text(_selectedLanguage),
            onTap: () => _showLanguageDialog(),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text('Currency'),
            subtitle: Text(_selectedCurrency),
            onTap: () => _showCurrencyDialog(),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Profile Settings'),
            onTap: () {
              // TODO: Navigate to profile settings
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Privacy & Security'),
            onTap: () {
              // TODO: Navigate to privacy settings
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & Support'),
            onTap: () {
              // TODO: Navigate to help & support
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Art Gallery',
                applicationVersion: '1.0.0',
                applicationIcon: const FlutterLogo(size: 48),
                children: [
                  const Text(
                    'A beautiful art gallery app for discovering and collecting artwork.',
                  ),
                ],
              );
            },
          ),
        ],
      ),
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
            ListTile(
              title: const Text('English'),
              trailing: _selectedLanguage == 'English'
                  ? const Icon(Icons.check, color: Colors.deepPurple)
                  : null,
              onTap: () {
                setState(() {
                  _selectedLanguage = 'English';
                });
                _saveSettings();
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Spanish'),
              trailing: _selectedLanguage == 'Spanish'
                  ? const Icon(Icons.check, color: Colors.deepPurple)
                  : null,
              onTap: () {
                setState(() {
                  _selectedLanguage = 'Spanish';
                });
                _saveSettings();
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('French'),
              trailing: _selectedLanguage == 'French'
                  ? const Icon(Icons.check, color: Colors.deepPurple)
                  : null,
              onTap: () {
                setState(() {
                  _selectedLanguage = 'French';
                });
                _saveSettings();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCurrencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Currency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('USD (\$)'),
              trailing: _selectedCurrency == 'USD'
                  ? const Icon(Icons.check, color: Colors.deepPurple)
                  : null,
              onTap: () {
                setState(() {
                  _selectedCurrency = 'USD';
                });
                _saveSettings();
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('EUR (€)'),
              trailing: _selectedCurrency == 'EUR'
                  ? const Icon(Icons.check, color: Colors.deepPurple)
                  : null,
              onTap: () {
                setState(() {
                  _selectedCurrency = 'EUR';
                });
                _saveSettings();
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('GBP (£)'),
              trailing: _selectedCurrency == 'GBP'
                  ? const Icon(Icons.check, color: Colors.deepPurple)
                  : null,
              onTap: () {
                setState(() {
                  _selectedCurrency = 'GBP';
                });
                _saveSettings();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
} 