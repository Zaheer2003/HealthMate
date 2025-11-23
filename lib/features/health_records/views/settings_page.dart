
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_records_app/features/auth/services/auth_service.dart';
import 'package:student_records_app/features/auth/views/login_page.dart';
import 'package:student_records_app/services/theme_provider.dart';
import '../controllers/health_record_controller.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController _stepsGoalController;
  late TextEditingController _caloriesGoalController;
  late TextEditingController _waterGoalController;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _dobController;
  XFile? _pickedProfileImage; // For new selected image
  DateTime? _selectedDate;

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    final controller = Provider.of<HealthRecordController>(context, listen: false);
    _stepsGoalController = TextEditingController(text: controller.defaultGoalSteps.toString());
    _caloriesGoalController = TextEditingController(text: controller.defaultGoalCalories.toString());
    _waterGoalController = TextEditingController(text: controller.defaultGoalWater.toString());

    final userData = _authService.currentUserData;
    _nameController = TextEditingController(text: userData?['name'] ?? '');
    _phoneController = TextEditingController(text: userData?['phone'] ?? '');
    _selectedDate = userData?['dateOfBirth'];
    _dobController = TextEditingController(
        text: _selectedDate != null ? DateFormat('yyyy-MM-dd').format(_selectedDate!) : '');
  }

  @override
  void dispose() {
    _stepsGoalController.dispose();
    _caloriesGoalController.dispose();
    _waterGoalController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedProfileImage = pickedFile;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _saveGoals() async {
    final controller = Provider.of<HealthRecordController>(context, listen: false);
    await controller.setGoalSteps(int.tryParse(_stepsGoalController.text) ?? controller.defaultGoalSteps);
    await controller.setGoalCalories(int.tryParse(_caloriesGoalController.text) ?? controller.defaultGoalCalories);
    await controller.setGoalWater(int.tryParse(_waterGoalController.text) ?? controller.defaultGoalWater);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Goals saved successfully!')),
    );
  }

  Future<void> _saveProfile() async {
    if (_authService.currentUserEmail == null) return;

    await _authService.updateUserData(
      _authService.currentUserEmail!,
      name: _nameController.text,
      phone: _phoneController.text,
      profilePictureUrl: _pickedProfileImage?.path,
      dateOfBirth: _selectedDate,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!')),
    );
  }

  void _logout() async {
    await AuthService().logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User Profile Section
            _buildModernCard(
              context,
              title: 'Profile',
              icon: Icons.person_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 56,
                            backgroundImage: _pickedProfileImage != null
                                ? (kIsWeb
                                    ? NetworkImage(_pickedProfileImage!.path)
                                    : FileImage(File(_pickedProfileImage!.path)))
                                    as ImageProvider
                                : (AuthService()
                                            .currentUserData?['profilePictureUrl'] !=
                                        null
                                    ? (kIsWeb
                                        ? NetworkImage(AuthService()
                                            .currentUserData!['profilePictureUrl'])
                                        : FileImage(File(AuthService()
                                            .currentUserData!['profilePictureUrl'])))
                                        as ImageProvider
                                    : null),
                            child: _pickedProfileImage == null &&
                                    AuthService().currentUserData
                                            ?['profilePictureUrl'] ==
                                        null
                                ? Icon(Icons.camera_alt, size: 32)
                                : null,
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.4),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.all(8),
                              child: Icon(Icons.edit, color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildSettingsTextField(
                    controller: _nameController,
                    label: 'Name',
                    icon: Icons.person_outline_rounded,
                  ),
                  SizedBox(height: 16),
                  _buildSettingsTextField(
                    controller: _phoneController,
                    label: 'Phone',
                    icon: Icons.phone_outlined,
                  ),
                  SizedBox(height: 16),
                  _buildSettingsTextField(
                    controller: _dobController,
                    label: 'Date of Birth',
                    icon: Icons.calendar_today_rounded,
                    readOnly: true,
                    onTap: () => _selectDate(context),
                  ),
                  SizedBox(height: 16),
                  _buildActionButton(
                    context,
                    label: 'Save Profile',
                    icon: Icons.check_circle_outline_rounded,
                    onPressed: _saveProfile,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // App Preferences
            _buildModernCard(
              context,
              title: 'Appearance',
              icon: Icons.palette_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, child) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SwitchListTile(
                          title: Text(
                            'Dark Mode',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          secondary: Icon(
                            themeProvider.themeMode == ThemeMode.dark
                                ? Icons.dark_mode_rounded
                                : Icons.light_mode_rounded,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          value: themeProvider.themeMode == ThemeMode.dark,
                          onChanged: (value) {
                            themeProvider.toggleTheme(value);
                          },
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Daily Goals
            _buildModernCard(
              context,
              title: 'Daily Goals',
              icon: Icons.track_changes_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      _buildGoalInputCard(
                        controller: _stepsGoalController,
                        label: 'Steps',
                        icon: Icons.directions_walk_rounded,
                        color: Color(0xFF34C759),
                      ),
                      _buildGoalInputCard(
                        controller: _caloriesGoalController,
                        label: 'Calories',
                        icon: Icons.local_fire_department_rounded,
                        color: Color(0xFFFF3B30),
                      ),
                      _buildGoalInputCard(
                        controller: _waterGoalController,
                        label: 'Water (ml)',
                        icon: Icons.water_drop_rounded,
                        color: Color(0xFF00B4DB),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  _buildActionButton(
                    context,
                    label: 'Save Goals',
                    icon: Icons.check_circle_outline_rounded,
                    onPressed: _saveGoals,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Logout
            _buildActionButton(
              context,
              label: 'Logout',
              icon: Icons.logout_rounded,
              onPressed: _logout,
              color: Theme.of(context).colorScheme.error,
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildModernCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        SizedBox(height: 6),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          decoration: InputDecoration(
            prefixIcon: Icon(icon,
                color: Theme.of(context).colorScheme.primary, size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context)
                    .colorScheme
                    .outlineVariant
                    .withOpacity(0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.5),
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildGoalInputCard({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: color.withOpacity(0.3)),
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.5),
                contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              ),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 14.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 22),
                SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
