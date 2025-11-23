import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/health_record_controller.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:fl_chart/fl_chart.dart'; // Import fl_chart
import 'package:student_records_app/features/auth/services/auth_service.dart';
import 'package:student_records_app/features/health_records/views/step_history_page.dart';
import 'package:student_records_app/features/health_records/views/calories_history_page.dart';
import 'package:student_records_app/features/health_records/views/water_history_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HealthRecordController>(
      builder: (context, controller, child) {
        // Filter records for today
        final today = DateTime.now();
        final todayRecords = controller.healthRecords.where((record) {
          return record.date.year == today.year &&
                 record.date.month == today.month &&
                 record.date.day == today.day;
        }).toList();

        final totalStepsToday = todayRecords.fold<int>(0, (sum, record) => sum + record.steps);
        final totalCaloriesToday = todayRecords.fold<int>(0, (sum, record) => sum + record.calories);
        final totalWaterToday = todayRecords.fold<int>(0, (sum, record) => sum + record.water);

        // Get goals from controller
        final goalSteps = controller.defaultGoalSteps;
        final goalCalories = controller.defaultGoalCalories;
        final goalWater = controller.defaultGoalWater;

        // Prepare data for the charts (e.g., last 7 days of steps, calories, water)
        Map<String, int> dailySteps = {};
        Map<String, int> dailyCalories = {};
        Map<String, int> dailyWater = {};
        for (int i = 6; i >= 0; i--) {
          final date = today.subtract(Duration(days: i));
          final formattedDate = DateFormat('MM/dd').format(date);
          dailySteps[formattedDate] = 0;
          dailyCalories[formattedDate] = 0;
          dailyWater[formattedDate] = 0;
        }

        for (var record in controller.healthRecords) {
          final formattedDate = DateFormat('MM/dd').format(record.date);
          if (dailySteps.containsKey(formattedDate)) {
            dailySteps[formattedDate] = (dailySteps[formattedDate] ?? 0) + record.steps;
            dailyCalories[formattedDate] = (dailyCalories[formattedDate] ?? 0) + record.calories;
            dailyWater[formattedDate] = (dailyWater[formattedDate] ?? 0) + record.water;
          }
        }

        List<String> dates = dailySteps.keys.toList();

        // Prepare line chart series as lists of doubles for dedicated chart sections
        final caloriesValues = dates.map((d) => (dailyCalories[d] ?? 0).toDouble()).toList();
        final waterValues = dates.map((d) => (dailyWater[d] ?? 0).toDouble()).toList();

        return SafeArea(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.surface,
                  Theme.of(context).colorScheme.surface.withOpacity(0.95),
                ],
              ),
            ),
            child: Column(
              children: [
                // Modern Header
                _buildModernHeader(context, today),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          // Search Bar with modern styling
                          _buildSearchBar(context),
                          SizedBox(height: 32),
                          // Today's Summary Section
                          Text(
                            'Today\'s Overview',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: 16),
                          GridView.count(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 14.0,
                            mainAxisSpacing: 14.0,
                            children: [
                              _buildModernSummaryCard(
                                context,
                                'Steps',
                                totalStepsToday,
                                goalSteps,
                                Icons.directions_walk,
                                [Color(0xFF34C759), Color(0xFF30B0A0)],
                              ),
                              _buildModernSummaryCard(
                                context,
                                'Calories',
                                totalCaloriesToday,
                                goalCalories,
                                Icons.local_fire_department,
                                [Color(0xFFFF3B30), Color(0xFFFF9500)],
                              ),
                              _buildModernSummaryCard(
                                context,
                                'Water',
                                totalWaterToday,
                                goalWater,
                                Icons.water_drop,
                                [Color(0xFF00B4DB), Color(0xFF0083B0)],
                              ),
                              _buildHealthScoreCard(context),
                            ],
                          ),
                          SizedBox(height: 36),
                          // Chart Section
                          Text(
                            'Weekly Steps',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: 16),
                          _buildLineChartContainer(
                            context,
                            'Steps',
                            dailySteps.values.map((v) => v.toDouble()).toList(),
                            dates,
                            [Color(0xFF34C759), Color(0xFF30B0A0)],
                          ),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const StepHistoryPage(),
                                    ),
                                  );
                                },
                                icon: Icon(Icons.arrow_forward_rounded,
                                    color: Theme.of(context).colorScheme.primary),
                                label: Text(
                                  'Detailed History',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 32),
                          // Calories Weekly Chart
                          Text(
                            'Weekly Calories',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: 16),
                          _buildLineChartContainer(
                            context,
                            'Calories',
                            caloriesValues,
                            dates,
                            [Color(0xFFFF3B30), Color(0xFFFF9500)],
                          ),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const CaloriesHistoryPage(),
                                    ),
                                  );
                                },
                                icon: Icon(Icons.arrow_forward_rounded,
                                    color: Theme.of(context).colorScheme.primary),
                                label: Text(
                                  'Detailed History',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Water Weekly Chart
                          Text(
                            'Weekly Water Intake',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: 16),
                          _buildLineChartContainer(
                            context,
                            'Water (ml)',
                            waterValues,
                            dates,
                            [Color(0xFF00B4DB), Color(0xFF0083B0)],
                          ),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const WaterHistoryPage(),
                                    ),
                                  );
                                },
                                icon: Icon(Icons.arrow_forward_rounded,
                                    color: Theme.of(context).colorScheme.primary),
                                label: Text(
                                  'Detailed History',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernHeader(BuildContext context, DateTime today) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.9),
            Theme.of(context).colorScheme.primary.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // User Profile Section
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.6),
                          width: 2.5,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 28,
                        backgroundImage: AuthService().currentUserData?['profilePictureUrl'] != null
                            ? (kIsWeb
                                ? NetworkImage(AuthService().currentUserData!['profilePictureUrl'])
                                : FileImage(File(AuthService().currentUserData!['profilePictureUrl'])))
                                as ImageProvider
                            : null,
                        child: AuthService().currentUserData?['profilePictureUrl'] == null
                            ? Icon(Icons.person, size: 24, color: Colors.white)
                            : null,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          AuthService().currentUserData?['name'] ?? 'User',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Notification Icon
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.notifications_rounded, color: Colors.white),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Date and Status
            Row(
              children: [
                Icon(Icons.calendar_today_rounded, color: Colors.white.withOpacity(0.8), size: 18),
                SizedBox(width: 8),
                Text(
                  DateFormat('EEEE, MMMM d, yyyy').format(today),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        decoration: InputDecoration(
          hintText: 'Search records...',
          prefixIcon: Icon(Icons.search_rounded,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.6)),
          suffixIcon: Icon(Icons.tune_rounded,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.6)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildModernSummaryCard(
    BuildContext context,
    String label,
    int currentValue,
    int goalValue,
    IconData icon,
    List<Color> gradientColors,
  ) {
    final progress = goalValue > 0 ? currentValue / goalValue : 0.0;
    final progressPercent = (progress * 100).toStringAsFixed(0);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.15),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                gradientColors[0].withOpacity(0.9),
                gradientColors[1].withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: Colors.white, size: 24),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$progressPercent%',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        '$currentValue',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Goal: $goalValue',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      backgroundColor: Colors.white.withOpacity(0.2),
                      color: Colors.white,
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHealthScoreCard(BuildContext context) {
    // Calculate a simple health score based on all available data
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF9C27B0).withOpacity(0.15),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF9C27B0).withOpacity(0.9),
                Color(0xFF673AB7).withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.favorite_rounded, color: Colors.white, size: 24),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Good',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Health',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        '85/100',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Score',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: 0.85,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      color: Colors.white,
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLineChartContainer(
    BuildContext context,
    String label,
    List<double> values,
    List<String> dates,
    List<Color> gradientColors,
  ) {
    if (values.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text('No data available'),
        ),
      );
    }

    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Container(
      height: 260,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 12,
            spreadRadius: 2,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20.0),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            horizontalInterval: null,
            verticalInterval: null,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.2),
                strokeWidth: 0.8,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: isSmallScreen ? 2 : 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= dates.length) {
                    return SizedBox.shrink();
                  }
                  // Show short date format on small screens
                  final dateStr = isSmallScreen
                      ? dates[index].split('/')[1] // Show only day (e.g., "14")
                      : dates[index]; // Show full date (e.g., "11/14")
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      dateStr,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 10 : 11,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  );
                },
                reservedSize: isSmallScreen ? 24 : 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    ),
                  );
                },
                reservedSize: 40,
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                values.length,
                (i) => FlSpot(i.toDouble(), values[i]),
              ),
              isCurved: true,
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
              ),
              barWidth: 3.0,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    gradientColors[0].withOpacity(0.3),
                    gradientColors[1].withOpacity(0.1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          minY: 0,
          maxY: (maxValue * 1.15).clamp(1.0, double.infinity),
        ),
      ),
    );
  }
}