import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/user_service.dart';
import '../../services/user_preferences_service.dart';
import '../../utils/currency_utils.dart';

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
  late final UserService _userService;
  late final UserPreferencesService _prefsService;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _loadSettings();
  }

  Future<void> _initializeServices() async {
    _userService = await UserService.create();
    _prefsService = UserPreferencesService();
    setState(() {
      _isLoggedIn = _userService.isLoggedIn;
    });
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
    await _prefsService.setPreferredCurrency(_selectedCurrency);
  }

  void _handleAuthAction() {
    if (_isLoggedIn) {
      // Logout
      _userService.logout();
      setState(() {
        _isLoggedIn = false;
      });
      Navigator.pushReplacementNamed(context, '/signin');
    } else {
      // Navigate to sign in
      Navigator.pushNamed(context, '/signin');
    }
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Language changed to English')),
                );
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Idioma cambiado a español')),
                );
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Langue changée en français')),
                );
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Currency changed to USD')),
                );
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Currency changed to EUR')),
                );
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Currency changed to GBP')),
                );
              },
            ),
            ListTile(
              title: const Text('JPY (¥)'),
              trailing: _selectedCurrency == 'JPY'
                  ? const Icon(Icons.check, color: Colors.deepPurple)
                  : null,
              onTap: () {
                setState(() {
                  _selectedCurrency = 'JPY';
                });
                _saveSettings();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Currency changed to JPY')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDarkMode ? Colors.grey[900] : Colors.white,
      appBar: AppBar(
        backgroundColor: _isDarkMode ? Colors.grey[800] : Colors.deepPurple[100],
        elevation: 0,
        title: Text(
          'Settings',
          style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black87),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: _isDarkMode ? Colors.white : Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Account',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: _isDarkMode ? Colors.grey[800] : Colors.white,
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.person,
                      color: _isDarkMode ? Colors.white : Colors.black87,
                    ),
                    title: Text(
                      _isLoggedIn ? 'Logout' : 'Sign In',
                      style: TextStyle(
                        color: _isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    onTap: _handleAuthAction,
                  ),
                  if (!_isLoggedIn) ...[
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(
                        Icons.person_add,
                        color: _isDarkMode ? Colors.white : Colors.black87,
                      ),
                      title: Text(
                        'Sign Up',
                        style: TextStyle(
                          color: _isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, '/signup');
                      },
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Preferences Section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Preferences',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: _isDarkMode ? Colors.grey[800] : Colors.white,
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.dark_mode,
                      color: _isDarkMode ? Colors.white : Colors.black87,
                    ),
                    title: Text(
                      'Dark Mode',
                      style: TextStyle(
                        color: _isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    trailing: Switch(
                      value: _isDarkMode,
                      onChanged: (value) {
                        setState(() {
                          _isDarkMode = value;
                        });
                        _saveSettings();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              value ? 'Dark mode enabled' : 'Dark mode disabled',
                            ),
                          ),
                        );
                      },
                      activeColor: Colors.deepPurple,
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      Icons.notifications,
                      color: _isDarkMode ? Colors.white : Colors.black87,
                    ),
                    title: Text(
                      'Notifications',
                      style: TextStyle(
                        color: _isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    trailing: Switch(
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        setState(() {
                          _notificationsEnabled = value;
                        });
                        _saveSettings();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              value
                                  ? 'Notifications enabled'
                                  : 'Notifications disabled',
                            ),
                          ),
                        );
                      },
                      activeColor: Colors.deepPurple,
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      Icons.language,
                      color: _isDarkMode ? Colors.white : Colors.black87,
                    ),
                    title: Text(
                      'Language',
                      style: TextStyle(
                        color: _isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      _selectedLanguage,
                      style: TextStyle(
                        color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    onTap: () => _showLanguageDialog(),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      Icons.attach_money,
                      color: _isDarkMode ? Colors.white : Colors.black87,
                    ),
                    title: Text(
                      'Currency',
                      style: TextStyle(
                        color: _isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      _selectedCurrency,
                      style: TextStyle(
                        color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    onTap: () => _showCurrencyDialog(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Other Settings Section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Other Settings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: _isDarkMode ? Colors.grey[800] : Colors.white,
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.person_outline,
                      color: _isDarkMode ? Colors.white : Colors.black87,
                    ),
                    title: Text(
                      'Profile Settings',
                      style: TextStyle(
                        color: _isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/profile-details');
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      Icons.security,
                      color: _isDarkMode ? Colors.white : Colors.black87,
                    ),
                    title: Text(
                      'Privacy & Security',
                      style: TextStyle(
                        color: _isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    onTap: () {
                      // TODO: Navigate to privacy settings
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      Icons.help_outline,
                      color: _isDarkMode ? Colors.white : Colors.black87,
                    ),
                    title: Text(
                      'Help & Support',
                      style: TextStyle(
                        color: _isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    onTap: () {
                      // TODO: Navigate to help & support
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      Icons.info_outline,
                      color: _isDarkMode ? Colors.white : Colors.black87,
                    ),
                    title: Text(
                      'About',
                      style: TextStyle(
                        color: _isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'Art Gallery',
                        applicationVersion: '1.0.0',
                        applicationIcon: const FlutterLogo(size: 48),
                        children: [
                          Text(
                            'A beautiful art gallery app for discovering and collecting artwork.',
                            style: TextStyle(
                              color: _isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
} 