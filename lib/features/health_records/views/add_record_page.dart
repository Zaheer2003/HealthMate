
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider
import '../controllers/health_record_controller.dart'; // Import HealthRecordController
import '../models/health_record.dart'; // Import HealthRecord
import 'package:intl/intl.dart'; // For date formatting

class AddRecordPage extends StatefulWidget {
  final HealthRecord? recordToEdit; // Optional parameter for editing

  const AddRecordPage({Key? key, this.recordToEdit}) : super(key: key);

  @override
  _AddRecordPageState createState() => _AddRecordPageState();
}

class _AddRecordPageState extends State<AddRecordPage> {
  final _formKey = GlobalKey<FormState>();
  final _stepsController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _waterController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  int? _recordId; // To store the ID of the record being edited

  @override
  void initState() {
    super.initState();
    if (widget.recordToEdit != null) {
      _recordId = widget.recordToEdit!.id;
      _selectedDate = widget.recordToEdit!.date;
      _stepsController.text = widget.recordToEdit!.steps.toString();
      _caloriesController.text = widget.recordToEdit!.calories.toString();
      _waterController.text = widget.recordToEdit!.water.toString();
    }
  }

  @override
  void dispose() {
    _stepsController.dispose();
    _caloriesController.dispose();
    _waterController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveHealthRecord() async {
    if (_formKey.currentState!.validate()) {
      final healthRecord = HealthRecord(
        id: _recordId, // Pass ID if editing
        date: _selectedDate,
        steps: int.parse(_stepsController.text),
        calories: int.parse(_caloriesController.text),
        water: int.parse(_waterController.text),
      );
      // Access controller via Provider
      final controller = Provider.of<HealthRecordController>(context, listen: false);

      if (_recordId == null) {
        await controller.addHealthRecord(healthRecord);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Health record added!')),
        );
      } else {
        await controller.updateHealthRecord(healthRecord);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Health record updated!')),
        );
      }

      _stepsController.clear();
      _caloriesController.clear();
      _waterController.clear();
      setState(() {
        _selectedDate = DateTime.now();
      });
      Navigator.pop(context); // Pop back to HomePage after saving
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _recordId == null ? 'Add New Record' : 'Edit Record',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Date Picker Card
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.9),
                      Theme.of(context).colorScheme.primary.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _selectDate(context),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.calendar_today_rounded,
                                color: Colors.white, size: 24),
                          ),
                          SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Select Date',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                DateFormat('EEEE, MMMM d, yyyy')
                                    .format(_selectedDate),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 28),
              Text(
                'Health Metrics',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 16),
              // Steps Field
              _buildModernInputField(
                controller: _stepsController,
                labelText: 'Steps Walked',
                icon: Icons.directions_walk_rounded,
                keyboardType: TextInputType.number,
                gradientColors: [Color(0xFF34C759), Color(0xFF30B0A0)],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter steps';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              // Calories Field
              _buildModernInputField(
                controller: _caloriesController,
                labelText: 'Calories Burned',
                icon: Icons.local_fire_department_rounded,
                keyboardType: TextInputType.number,
                gradientColors: [Color(0xFFFF3B30), Color(0xFFFF9500)],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter calories';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              // Water Field
              _buildModernInputField(
                controller: _waterController,
                labelText: 'Water Intake (ml)',
                icon: Icons.water_drop_rounded,
                keyboardType: TextInputType.number,
                gradientColors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter water intake';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 32),
              // Save Button
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _saveHealthRecord,
                    borderRadius: BorderRadius.circular(14),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline_rounded,
                              color: Colors.white, size: 24),
                          SizedBox(width: 8),
                          Text(
                            _recordId == null ? 'Add Record' : 'Update Record',
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernInputField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    required List<Color> gradientColors,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: gradientColors[0].withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            decoration: InputDecoration(
              prefixIcon: Container(
                margin: EdgeInsets.only(right: 8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Icon(icon, color: gradientColors[0], size: 24),
                ),
              ),
              hintText: 'Enter $labelText',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              contentPadding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0),
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                fontWeight: FontWeight.w500,
              ),
              errorStyle: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
