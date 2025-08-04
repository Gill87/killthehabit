import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rehabit/auth/presentation/cubits/auth_cubit.dart';
import 'package:rehabit/services/android_screen_time_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> appUsageData = [];
  int totalScreenTime = 0; // in milliseconds
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadScreenTimeData();
  }

  // Function to handle logout
  void logout() {
    AuthCubit authCubit = context.read<AuthCubit>();
    authCubit.logout();
  }

  Future<void> _loadScreenTimeData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Get total screen time
      int total = await AndroidScreenTimeService.getTotalScreenTime();
      
      // Get individual app usage (optional - for future use)
      List<Map<String, dynamic>> appData = await AndroidScreenTimeService.getUsageStats();

      setState(() {
        totalScreenTime = total;
        appUsageData = appData;
      });
    } catch (e) {
      print("Error loading screen time data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading screen time: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadScreenTimeData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Start App Bar
      appBar: AppBar(
        title: Text(
          'Kill the Habit',
          style: GoogleFonts.ubuntu(fontSize: 24),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: isLoading ? null : _refreshData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => logout(),
          ),
        ],
      ),
      // End App Bar

      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                Center(
                  child: Text(
                    "Today's Screen Time",
                    style: GoogleFonts.ubuntu(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Total Screen Time Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade400, Colors.blue.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.shade200,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.phone_android,
                        size: 48,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Total Screen Time',
                        style: GoogleFonts.ubuntu(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (isLoading)
                        const CircularProgressIndicator(color: Colors.white)
                      else
                        Text(
                          AndroidScreenTimeService.formatTime(totalScreenTime),
                          style: GoogleFonts.ubuntu(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        'Last 24 hours',
                        style: GoogleFonts.ubuntu(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Quick Stats Row
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Apps Used',
                        '${appUsageData.length}',
                        Icons.apps,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'Avg per App',
                        appUsageData.isNotEmpty
                            ? AndroidScreenTimeService.formatTime(
                                totalScreenTime ~/ appUsageData.length)
                            : '0m',
                        Icons.timer,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Most Used Apps Preview
                if (appUsageData.isNotEmpty) ...[
                  Text(
                    'Most Used Apps',
                    style: GoogleFonts.ubuntu(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...appUsageData.take(3).map((app) {
                    String packageName = app['packageName'] ?? 'Unknown';
                    int timeInForeground = app['totalTimeInForeground'] ?? 0;
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: Text(
                            packageName.split('.').last.substring(0, 1).toUpperCase(),
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          AndroidScreenTimeService.getFriendlyAppName(packageName),
                          style: GoogleFonts.ubuntu(fontWeight: FontWeight.w500),
                        ),
                        trailing: Text(
                          AndroidScreenTimeService.formatTime(timeInForeground),
                          style: GoogleFonts.ubuntu(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade600,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],

                const SizedBox(height: 100), // Space for bottom nav
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.ubuntu(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.ubuntu(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}