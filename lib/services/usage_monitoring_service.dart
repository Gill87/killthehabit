import 'dart:async';
import 'dart:io';
import 'package:rehabit/database/app_limit_database.dart';
import 'package:rehabit/database/app_usage_database.dart';
import 'package:rehabit/services/android_screen_time_service.dart';
import 'package:rehabit/services/notification_service.dart';

class UsageMonitoringService {
  static final UsageMonitoringService _instance = UsageMonitoringService._internal();
  factory UsageMonitoringService() => _instance;
  UsageMonitoringService._internal();

  Timer? _monitoringTimer;
  bool _isMonitoring = false;
  
  final AppLimitDatabase _limitDb = AppLimitDatabase();
  final AppUsageDatabase _usageDb = AppUsageDatabase();
  final NotificationService _notificationService = NotificationService();
  
  // Track apps that have already been notified today
  final Set<String> _notifiedApps80 = {};
  final Set<String> _notifiedApps100 = {};

  bool get isMonitoring => _isMonitoring;

  // Start monitoring app usage
  Future<void> startMonitoring() async {
    if (_isMonitoring || !Platform.isAndroid) return;
    
    _isMonitoring = true;
    await _initializeServices();
    _loadTodayNotifications();
    
    // Check usage every 2 minutes
    _monitoringTimer = Timer.periodic(
      const Duration(minutes: 2), 
      (timer) => _checkAppUsage(),
    );
    
    print('Usage monitoring started');
  }

  // Stop monitoring
  void stopMonitoring() {
    _monitoringTimer?.cancel();
    _isMonitoring = false;
    print('Usage monitoring stopped');
  }

  // Initialize required services
  Future<void> _initializeServices() async {
    await _notificationService.initNotifications();
    _limitDb.loadData();
    _usageDb.loadData();
  }

  // Load today's notification history to avoid duplicate notifications
  void _loadTodayNotifications() {
    _notifiedApps80.clear();
    _notifiedApps100.clear();
    
    // You could load this from a separate tracking database if needed
    // For now, we'll rely on the notification sent flags in AppUsageDatabase
  }

  // Main method to check app usage and send notifications
  Future<void> _checkAppUsage() async {
    try {
      // Get current usage data
      List<Map<String, dynamic>> currentUsage = await AndroidScreenTimeService.getUsageStats();
      
      // Update usage database with current data
      for (var app in currentUsage) {
        String packageName = app['packageName'];
        int usageTime = app['totalTimeInForeground'];
        await _usageDb.saveAppUsage(packageName, usageTime);
      }
      
      // Check each app with limits
      for (var limit in _limitDb.appLimits) {
        String packageName = limit[0];
        int limitMinutes = limit[1];
        
        await _checkAppLimit(packageName, limitMinutes);
      }
      
    } catch (e) {
      print('Error in usage monitoring: $e');
    }
  }

  // Check individual app limit and send appropriate notifications
  Future<void> _checkAppLimit(String packageName, int limitMinutes) async {
    double usagePercentage = _usageDb.getUsagePercentage(packageName, limitMinutes);
    int todayUsageMillis = _usageDb.getTodayUsage(packageName);
    int todayUsageMinutes = (todayUsageMillis / (1000 * 60)).round();
    
    // Check for 100% limit exceeded
    if (usagePercentage >= 100.0 && !_notifiedApps100.contains(packageName)) {
      await _notificationService.showLimitExceededNotification(
        packageName: packageName,
        limitMinutes: limitMinutes,
        todayUsageMinutes: todayUsageMinutes,
      );
      
      _notifiedApps100.add(packageName);
      print('Limit exceeded notification sent for $packageName');
    }
    
    // Check for 80% warning (only if 100% notification hasn't been sent)
    else if (usagePercentage >= 80.0 && 
             !_notifiedApps80.contains(packageName) && 
             !_usageDb.wasNotificationSent(packageName)) {
      
      await _notificationService.showUsageWarningNotification(
        packageName: packageName,
        usagePercentage: usagePercentage,
        limitMinutes: limitMinutes,
        todayUsageMinutes: todayUsageMinutes,
      );
      
      await _usageDb.markNotificationSent(packageName);
      _notifiedApps80.add(packageName);
      print('80% warning notification sent for $packageName');
    }
  }

  // Reset daily notification tracking (call at midnight or app start)
  void resetDailyNotifications() {
    _notifiedApps80.clear();
    _notifiedApps100.clear();
    print('Daily notifications reset');
  }

  // Send daily summary notification
  Future<void> sendDailySummary() async {
    try {
      int totalScreenTime = await AndroidScreenTimeService.getTotalScreenTime();
      
      int totalAppsWithLimits = _limitDb.appLimits.length;
      int appsOverLimit = 0;
      
      for (var limit in _limitDb.appLimits) {
        String packageName = limit[0];
        int limitMinutes = limit[1];
        double usagePercentage = _usageDb.getUsagePercentage(packageName, limitMinutes);
        
        if (usagePercentage >= 100.0) {
          appsOverLimit++;
        }
      }
      
      await _notificationService.showDailySummaryNotification(
        totalScreenTimeMillis: totalScreenTime,
        totalAppsWithLimits: totalAppsWithLimits,
        appsOverLimit: appsOverLimit,
      );
      
      print('Daily summary notification sent');
    } catch (e) {
      print('Error sending daily summary: $e');
    }
  }

  // Get current monitoring status
  Map<String, dynamic> getMonitoringStatus() {
    return {
      'isMonitoring': _isMonitoring,
      'appsTracked': _limitDb.appLimits.length,
      'notified80Today': _notifiedApps80.length,
      'notified100Today': _notifiedApps100.length,
    };
  }

  // Method to manually trigger a usage check (for testing)
  Future<void> triggerManualCheck() async {
    if (!_isMonitoring) {
      await _initializeServices();
    }
    await _checkAppUsage();
  }

  // Clean up resources
  void dispose() {
    stopMonitoring();
  }
}

// Extension to add usage monitoring to your main app
extension UsageMonitoringExtension on UsageMonitoringService {
  // Schedule daily summary notification for a specific time (e.g., 9 PM)
  void scheduleDailySummary() {
    final now = DateTime.now();
    var scheduledTime = DateTime(now.year, now.month, now.day, 21, 0); // 9 PM
    
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }
    
    final timeUntilSummary = scheduledTime.difference(now);
    
    Timer(timeUntilSummary, () {
      sendDailySummary();
      // Schedule next day's summary
      Timer.periodic(const Duration(days: 1), (timer) {
        sendDailySummary();
        resetDailyNotifications();
      });
    });
  }
}