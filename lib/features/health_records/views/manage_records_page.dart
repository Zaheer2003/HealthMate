
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider
import '../viewmodels/health_record_controller.dart'; // Import HealthRecordController
import '../models/health_record.dart'; // Import HealthRecord
import 'package:intl/intl.dart'; // For date formatting
import 'add_record_page.dart'; // Import AddRecordPage

class ManageRecordsPage extends StatefulWidget {
  @override
  _ManageRecordsPageState createState() => _ManageRecordsPageState();
}

class _ManageRecordsPageState extends State<ManageRecordsPage> {
  TextEditingController _searchDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchDateController.addListener(() {
      setState(() {
        // Trigger rebuild to re-apply filter based on search date
      });
    });
  }

  @override
  void dispose() {
    _searchDateController.dispose();
    super.dispose();
  }

  void _deleteHealthRecord(int id) async {
    final bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this record?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    ) ?? false; // Default to false if dialog is dismissed

    if (confirmDelete) {
      await Provider.of<HealthRecordController>(context, listen: false).deleteHealthRecord(id); // Delete health record
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Health record deleted!')),
      );
    }
  }

  void _editHealthRecord(HealthRecord record) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddRecordPage(recordToEdit: record),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HealthRecordController>(
      builder: (context, controller, child) {
        List<HealthRecord> recordsToDisplay = controller.healthRecords;

        if (_searchDateController.text.isNotEmpty) {
          recordsToDisplay = recordsToDisplay.where((record) {
            return DateFormat('yyyy-MM-dd').format(record.date) ==
                _searchDateController.text;
          }).toList();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Text(
                'Your Records',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 20),
              // Search/Filter
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _searchDateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Filter by date',
                    prefixIcon: Icon(Icons.filter_list_rounded,
                        color: Theme.of(context).colorScheme.primary),
                    suffixIcon: _searchDateController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.close_rounded,
                                color: Theme.of(context).colorScheme.primary),
                            onPressed: () {
                              _searchDateController.clear();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0),
                  ),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (picked != null) {
                      _searchDateController.text =
                          DateFormat('yyyy-MM-dd').format(picked);
                    }
                  },
                ),
              ),
              SizedBox(height: 20),
              // Records List
              Expanded(
                child: recordsToDisplay.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_rounded,
                              size: 64,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.3),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No records found',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.7),
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: recordsToDisplay.length,
                        itemBuilder: (context, index) {
                          final record = recordsToDisplay[index];
                          return _buildModernRecordCard(context, record);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModernRecordCard(BuildContext context, HealthRecord record) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('EEEE').format(record.date),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.8),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          DateFormat('MMM d, yyyy').format(record.date),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.edit_rounded,
                                color: Theme.of(context).colorScheme.primary),
                            onPressed: () => _editHealthRecord(record),
                            tooltip: 'Edit Record',
                            iconSize: 20,
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.delete_rounded,
                                color: Theme.of(context).colorScheme.error),
                            onPressed: () =>
                                _deleteHealthRecord(record.id!),
                            tooltip: 'Delete Record',
                            iconSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // Metrics Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                  children: [
                    _buildMetricTile(
                      context,
                      Icons.directions_walk_rounded,
                      'Steps',
                      record.steps.toString(),
                      Color(0xFF34C759),
                    ),
                    _buildMetricTile(
                      context,
                      Icons.local_fire_department_rounded,
                      'Calories',
                      record.calories.toString(),
                      Color(0xFFFF3B30),
                    ),
                    _buildMetricTile(
                      context,
                      Icons.water_drop_rounded,
                      'Water',
                      record.water.toString(),
                      Color(0xFF00B4DB),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile(BuildContext context, IconData icon, String label,
      String value, Color color) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.7),
              ),
            ),
            SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
