import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rehabit/auth/domain/entities/app_user.dart';
import 'package:rehabit/auth/presentation/cubits/auth_cubit.dart';
import 'package:rehabit/components/app_limit_tile.dart';
import 'package:rehabit/database/app_limit_database.dart';
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
  bool isAndroid = Platform.isAndroid;

  final _myBox = Hive.box("mybox");
  AppLimitDatabase db = AppLimitDatabase();

  @override
  void initState() {
    super.initState();

    // If first time opening app, then create default data
    if(_myBox.get("APPLIMITS") == null){
      db.createInitialData();
    } else {
      db.loadData();
    }

    if (isAndroid) {
      _androidLoadScreenTimeData();
    }
  }

// Function to handle logout
void logout() {
  AuthCubit authCubit = context.read<AuthCubit>();
  authCubit.logout();
}

void createNewLimit() {
  // Debug print to see what's happening
  print("createNewLimit called");
  print("appUsageData length: ${appUsageData.length}");
  
  // Don't return early - show dialog even if no apps
  String? selectedPackage = appUsageData.isNotEmpty ? appUsageData.first['packageName'] : null;
  Duration selectedDuration = const Duration(hours: 1);

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(builder: (context, dialogSetState) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  'Set App Time Limit',
                  style: GoogleFonts.ubuntu(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Dropdown to pick app
                appUsageData.isEmpty 
                  ? Text(
                      "No apps found. Please refresh screen time data first.",
                      style: TextStyle(color: Colors.grey[600]),
                    )
                  : DropdownButton<String>(
                      value: selectedPackage,
                      isExpanded: true,
                      items: appUsageData.map((app) {
                        String pkg = app['packageName'];
                        String friendlyName = AndroidScreenTimeService.getFriendlyAppName(pkg);
                        return DropdownMenuItem(
                          value: pkg,
                          child: Text(friendlyName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        dialogSetState(() {
                          selectedPackage = value;
                        });
                      },
                    ),
                const SizedBox(height: 20),

                // Time picker
                Container(
                  height: 200,
                  child: CupertinoTimerPicker(
                    mode: CupertinoTimerPickerMode.hm,
                    initialTimerDuration: selectedDuration,
                    onTimerDurationChanged: (Duration newDuration) {
                      dialogSetState(() {
                        selectedDuration = newDuration;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      child: Text('Cancel', style: GoogleFonts.ubuntu()),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    ElevatedButton(
                      child: Text('Save', style: GoogleFonts.ubuntu()),
                      onPressed: () async {
                        if (selectedPackage == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please select an app first')),
                          );
                          return;
                        }
                        
                        int totalMillis = selectedDuration.inMilliseconds;

                        if (totalMillis == 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please set a non-zero time limit')),
                          );
                          return;
                        }

                        await db.saveLimit(selectedPackage!, totalMillis);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Limit set for ${AndroidScreenTimeService.getFriendlyAppName(selectedPackage!)}')),
                        );
                        Navigator.of(context).pop();
                        _refreshData();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      });
    },
  );
}


  // Get Screen Time Data for Android
  Future<void> _androidLoadScreenTimeData() async {

    // Only for Android
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

  // Refresh Screen Time Data for Android
  Future<void> _refreshData() async {
    if (isAndroid) {
      await _androidLoadScreenTimeData();
    }
  }

  AppUser getUser() {
    AuthCubit authCubit = context.read<AuthCubit>();
    AppUser user = authCubit.currentUser;
    return user;
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
                    "Hey ${getUser().name} 👋",
                    style: GoogleFonts.ubuntu(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Combined Screen Time and Top Apps Card
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
                  child: Row(
                    children: [
                      // Left side - Total Screen Time
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
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
                      
                      // Divider
                      Container(
                        height: 120,
                        width: 1,
                        color: Colors.white.withOpacity(0.3),
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      
                      // Right side - Top 3 Apps
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Top Apps',
                              style: GoogleFonts.ubuntu(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (isLoading)
                              const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            else if (appUsageData.isEmpty)
                              Text(
                                'No app data',
                                style: GoogleFonts.ubuntu(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              )
                            else
                              ...appUsageData.take(3).map((app) {
                                String packageName = app['packageName'] ?? 'Unknown';
                                int timeInForeground = app['totalTimeInForeground'] ?? 0;
                                
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      // App icon placeholder
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Center(
                                          child: Text(
                                            packageName.split('.').last.substring(0, 1).toUpperCase(),
                                            style: GoogleFonts.ubuntu(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // App info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              AndroidScreenTimeService.getFriendlyAppName(packageName),
                                              style: GoogleFonts.ubuntu(
                                                fontSize: 12,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              AndroidScreenTimeService.formatTime(timeInForeground),
                                              style: GoogleFonts.ubuntu(
                                                fontSize: 11,
                                                color: Colors.white.withOpacity(0.8),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                
                // Additional content can go here if needed
                Center(
                  child: Row(
                    children: [
                      const Expanded(
                        child: Divider(
                          thickness: 2,
                          color: Colors.grey,
                          endIndent: 10,
                        ),
                      ),
                      Text(
                        "Your App Limits",
                        style: GoogleFonts.ubuntu(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Expanded(
                        child: Divider(
                          thickness: 2,
                          color: Colors.grey,
                          indent: 10,
                        ),
                      ),
                    ],
                  ),
                ),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: db.appLimits.length,
                  itemBuilder: (context, index) {
                    final limit = db.appLimits[index];
                    return AppLimitTile(
                      packageName: limit[0],
                      limitMinutes: limit[1],
                      onDelete: () {
                        setState(() {
                          db.appLimits.removeAt(index);
                          db.updateDatabase();
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: 100), // Space for bottom nav
              ],
            ),
          ),
        ),
      ),

      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: createNewLimit,
        child: const Icon(Icons.add, color: Colors.white,),
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
}