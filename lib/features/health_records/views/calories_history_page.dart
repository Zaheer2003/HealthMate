import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/health_record_controller.dart';
import 'package:intl/intl.dart';

class CaloriesHistoryPage extends StatelessWidget {
  const CaloriesHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calories History', style: TextStyle(fontWeight: FontWeight.w700)),
        elevation: 0,
      ),
      body: Consumer<HealthRecordController>(
        builder: (context, controller, child) {
          final records = List.from(controller.healthRecords)..sort((a, b) => b.date.compareTo(a.date));

          if (records.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_fire_department_rounded, size: 64, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
                  const SizedBox(height: 12),
                  Text('No calories records yet', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
                ],
              ),
            );
          }

          final totalCalories = records.fold<int>(0, (sum, r) => sum + (r.calories as int));
          final avgCalories = (totalCalories / records.length).toStringAsFixed(0);
          final maxCalories = records.map((r) => r.calories).reduce((a, b) => a > b ? a : b);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Theme.of(context).colorScheme.primary.withOpacity(0.9), Theme.of(context).colorScheme.primary.withOpacity(0.7)]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text('Total Calories', style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text(totalCalories.toString(), style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _statColumn('Average', avgCalories, Colors.white.withOpacity(0.9)),
                          Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
                          _statColumn('Highest', maxCalories.toString(), Colors.white),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text('Detailed Records', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final r = records[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.local_fire_department_rounded, color: Colors.redAccent),
                        ),
                        title: Text('${r.calories} kcal', style: TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text(DateFormat('yyyy-MM-dd – h:mm a').format(r.date)),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _statColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: color.withOpacity(0.9), fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
