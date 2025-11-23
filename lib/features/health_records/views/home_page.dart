import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'add_record_page.dart';
import 'manage_records_page.dart';
import 'settings_page.dart';
import 'calories_history_page.dart';
import 'water_history_page.dart';
import 'step_history_page.dart';
import 'package:student_records_app/features/auth/services/auth_service.dart';
import 'package:student_records_app/features/auth/views/login_page.dart';
import 'package:provider/provider.dart';
import 'package:student_records_app/services/theme_provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    DashboardPage(),
    ManageRecordsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Health Mate',
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.5),
        ),
        elevation: 0,
        centerTitle: false,
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              _buildDrawerHeader(context),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    ListTile(
                      leading: Icon(Icons.dashboard_rounded),
                      title: const Text('Dashboard'),
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          _selectedIndex = 0;
                        });
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.history_rounded),
                      title: const Text('Records'),
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          _selectedIndex = 1;
                        });
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.directions_walk_rounded, color: Color(0xFF34C759)),
                      title: const Text('Step History'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const StepHistoryPage()),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.local_fire_department_rounded, color: Colors.redAccent),
                      title: const Text('Calories History'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CaloriesHistoryPage()),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.water_drop_rounded, color: Colors.blueAccent),
                      title: const Text('Water History'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const WaterHistoryPage()),
                        );
                      },
                    ),
                    Divider(),
                    Consumer<ThemeProvider>(
                      builder: (context, themeProvider, child) {
                        return SwitchListTile(
                          secondary: Icon(themeProvider.themeMode == ThemeMode.dark
                              ? Icons.dark_mode_rounded
                              : Icons.light_mode_rounded),
                          title: const Text('Dark Mode'),
                          value: themeProvider.themeMode == ThemeMode.dark,
                          onChanged: (value) {
                            themeProvider.toggleTheme(value);
                          },
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.settings_rounded),
                      title: const Text('Settings'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SettingsPage()),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.help_outline_rounded),
                      title: const Text('Help'),
                      onTap: () {
                        Navigator.pop(context);
                        _showComingSoon(context, 'Help');
                      },
                    ),
                  ],
                ),
              ),
              SafeArea(
                child: ListTile(
                  leading: Icon(Icons.logout_rounded, color: Theme.of(context).colorScheme.error),
                  title: Text('Logout', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  onTap: () async {
                    await AuthService().logout();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                      (route) => false,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddRecordPage()),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add_rounded, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 12.0,
          elevation: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildNavItem(0, Icons.dashboard_rounded, 'Dashboard'),
              SizedBox(width: 56),
              _buildNavItem(1, Icons.history_rounded, 'Records'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    final color = isSelected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurface.withOpacity(0.5);

    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index),
        child: SizedBox(
          height: 56, // ensure we fit within the BottomAppBar's height
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(6),
                decoration: isSelected
                    ? BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      )
                    : null,
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 2),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    final user = AuthService().currentUserData;
    final profileUrl = user?['profilePictureUrl'];
    final name = user?['name'] ?? 'User';
    final email = user?['email'] ?? '';

    return UserAccountsDrawerHeader(
      accountName: Text(name),
      accountEmail: Text(email),
      currentAccountPicture: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.6), width: 2.0),
        ),
        child: CircleAvatar(
          radius: 28,
          backgroundImage: profileUrl != null
              ? (kIsWeb ? NetworkImage(profileUrl) : FileImage(File(profileUrl))) as ImageProvider?
              : null,
          child: profileUrl == null ? Icon(Icons.person, size: 28, color: Colors.white) : null,
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature is coming soon')),
    );
  }
}
