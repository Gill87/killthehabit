import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rehabit/auth/domain/entities/app_user.dart';
import 'package:rehabit/auth/presentation/cubits/auth_cubit.dart';
import 'package:rehabit/components/app_limit_tile.dart';
import 'package:rehabit/database/app_limit_database.dart';
import 'package:rehabit/database/app_usage_database.dart';
import 'package:rehabit/services/android_screen_time_service.dart';
import 'package:rehabit/services/notification_permissions.dart';
import 'package:rehabit/services/notification_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>  {
  List<Map<String, dynamic>> appUsageData = [];
  int totalScreenTime = 0; // in milliseconds
  bool isLoading = false;
  bool isAndroid = Platform.isAndroid;

  final _myBox = Hive.box("mybox");
  AppLimitDatabase db = AppLimitDatabase();
  AppUsageDatabase usageDb = AppUsageDatabase(); // Add usage database


  @override
  void initState() {
    super.initState();

    requestNotificationPermission();
    _initializeServices();

    // Initialize databases
    if(_myBox.get("APPLIMITS") == null){
      db.createInitialData();
    } else {
      db.loadData();
    }

    // Initialize usage database
    usageDb.loadData();

    if (isAndroid) {
      _androidLoadScreenTimeData();
    }
  }

  Future<void> _initializeServices() async {
    await NotificationService().initNotifications();
  }

  void requestNotificationPermission() async {
    bool hasNotificationPermission = await NotificationPermissions.checkNotificationPermission();

    if(!hasNotificationPermission) {
      await NotificationPermissions.requestNotificationPermission(context);
      hasNotificationPermission = await NotificationPermissions.checkNotificationPermission();
    }
  } 

  // NEW METHOD: Check for usage warnings and send notifications
  Future<void> _checkUsageWarnings() async {
    List<Map<String, dynamic>> appsNeedingWarning = usageDb.getAppsNeedingWarning(db.appLimits);
    
    for (var appWarning in appsNeedingWarning) {
      String packageName = appWarning['packageName'];
      int limitMinutes = appWarning['limitMinutes'];
      double usagePercentage = appWarning['usagePercentage'];
      int todayUsageMillis = appWarning['todayUsageMillis'];
      int todayUsageMinutes = (todayUsageMillis / (1000 * 60)).round();
      
      // Send 80% warning notification
      await NotificationService().showUsageWarningNotification(
        packageName: packageName,
        usagePercentage: usagePercentage,
        limitMinutes: limitMinutes,
        todayUsageMinutes: todayUsageMinutes,
      );
      
      // Mark notification as sent
      await usageDb.markNotificationSent(packageName);
      
      print('Warning notification sent for $packageName: ${usagePercentage.toInt()}%');
    }
  }

  // NEW METHOD: Check for exceeded limits and send notifications
  Future<void> _checkExceededLimits() async {
    for (var limit in db.appLimits) {
      String packageName = limit[0];
      int limitMinutes = limit[1];
      
      double usagePercentage = usageDb.getUsagePercentage(packageName, limitMinutes);
      
      if (usagePercentage >= 100.0) {
        int todayUsageMillis = usageDb.getTodayUsage(packageName);
        int todayUsageMinutes = (todayUsageMillis / (1000 * 60)).round();
        
        // Send limit exceeded notification
        await NotificationService().showLimitExceededNotification(
          packageName: packageName,
          limitMinutes: limitMinutes,
          todayUsageMinutes: todayUsageMinutes,
        );
        
        print('Limit exceeded notification sent for $packageName: ${usagePercentage.toInt()}%');
      }
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
                    : DropdownButtonFormField<String>(
                        value: selectedPackage,
                        isExpanded: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        dropdownColor: Colors.white,
                        items: appUsageData.map((app) {
                          String pkg = app['packageName'];
                          String friendlyName = AndroidScreenTimeService.getFriendlyAppName(pkg);
                          return DropdownMenuItem(
                            value: pkg,
                            child: Text(
                              friendlyName,
                              style: GoogleFonts.ubuntu(fontSize: 16, color: Colors.black),
                              overflow: TextOverflow.ellipsis,
                            ),
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


  // Get Screen Time Data for Android - UPDATED
  Future<void> _androidLoadScreenTimeData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Get total screen time
      int total = await AndroidScreenTimeService.getTotalScreenTime();
      
      // Get individual app usage
      List<Map<String, dynamic>> appData = await AndroidScreenTimeService.getUsageStats();

      // Save app usage data to database
      for (var app in appData) {
        String packageName = app['packageName'];
        int usageTime = app['totalTimeInForeground'];
        await usageDb.saveAppUsage(packageName, usageTime);
      }

      // Check for usage warnings and exceeded limits
      await _checkUsageWarnings();
      await _checkExceededLimits();

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
                              'Today',
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

    );
  }
}