import 'package:hive_flutter/hive_flutter.dart';

class AppUsageDatabase {
  List<Map<String, dynamic>> appUsageHistory = [];
  
  final _myBox = Hive.box("mybox");
  
  // Create initial data structure
  void createInitialData() {
    appUsageHistory = [];
  }
  
  // Load data from database
  void loadData() {
    var data = _myBox.get("APPUSAGE");
    if (data != null) {
      appUsageHistory = List<Map<String, dynamic>>.from(data);
    } else {
      createInitialData();
    }
  }
  
  // Update database
  Future<void> updateDatabase() async {
    await _myBox.put("APPUSAGE", appUsageHistory);
  }
  
  // Save or update app usage for today
  Future<void> saveAppUsage(String packageName, int usageTimeMillis) async {
    String today = DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD format
    
    // Check if there's already an entry for this app today
    bool found = false;
    for (int i = 0; i < appUsageHistory.length; i++) {
      if (appUsageHistory[i]['packageName'] == packageName && 
          appUsageHistory[i]['date'] == today) {
        appUsageHistory[i]['usageTimeMillis'] = usageTimeMillis;
        found = true;
        break;
      }
    }
    
    // If not found, add new entry
    if (!found) {
      appUsageHistory.add({
        'packageName': packageName,
        'date': today,
        'usageTimeMillis': usageTimeMillis,
        'notificationSent': false, // Track if 80% notification was sent
      });
    }
    
    await updateDatabase();
  }
  
  // Get today's usage for a specific app
  int getTodayUsage(String packageName) {
    String today = DateTime.now().toIso8601String().split('T')[0];
    
    for (var usage in appUsageHistory) {
      if (usage['packageName'] == packageName && usage['date'] == today) {
        return usage['usageTimeMillis'] ?? 0;
      }
    }
    return 0;
  }
  
  // Get all apps usage for today
  List<Map<String, dynamic>> getTodayUsageAll() {
    String today = DateTime.now().toIso8601String().split('T')[0];
    
    return appUsageHistory.where((usage) => usage['date'] == today).toList();
  }
  
  // Mark that notification was sent for an app today
  Future<void> markNotificationSent(String packageName) async {
    String today = DateTime.now().toIso8601String().split('T')[0];
    
    for (int i = 0; i < appUsageHistory.length; i++) {
      if (appUsageHistory[i]['packageName'] == packageName && 
          appUsageHistory[i]['date'] == today) {
        appUsageHistory[i]['notificationSent'] = true;
        break;
      }
    }
    
    await updateDatabase();
  }
  
  // Check if notification was already sent for an app today
  bool wasNotificationSent(String packageName) {
    String today = DateTime.now().toIso8601String().split('T')[0];
    
    for (var usage in appUsageHistory) {
      if (usage['packageName'] == packageName && usage['date'] == today) {
        return usage['notificationSent'] ?? false;
      }
    }
    return false;
  }
  
  // Clean old data (keep only last 30 days)
  Future<void> cleanOldData() async {
    DateTime thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    String cutoffDate = thirtyDaysAgo.toIso8601String().split('T')[0];
    
    appUsageHistory.removeWhere((usage) => usage['date'].compareTo(cutoffDate) < 0);
    await updateDatabase();
  }
  
  // Get usage percentage compared to limit
  double getUsagePercentage(String packageName, int limitMinutes) {
    int todayUsageMillis = getTodayUsage(packageName);
    int limitMillis = limitMinutes * 60 * 1000;
    
    if (limitMillis == 0) return 0.0;
    
    return (todayUsageMillis / limitMillis) * 100;
  }
  
  // Check if app usage has reached 80% threshold
  bool hasReached80Percent(String packageName, int limitMinutes) {
    double percentage = getUsagePercentage(packageName, limitMinutes);
    return percentage >= 80.0;
  }
  
  // Get apps that need 80% warning notification
  List<Map<String, dynamic>> getAppsNeedingWarning(List appLimits) {
    List<Map<String, dynamic>> appsNeedingWarning = [];
    
    for (var limit in appLimits) {
      String packageName = limit[0];
      int limitMinutes = limit[1];
      
      // Check if app has reached 80% and notification hasn't been sent
      if (hasReached80Percent(packageName, limitMinutes) && 
          !wasNotificationSent(packageName)) {
        double percentage = getUsagePercentage(packageName, limitMinutes);
        appsNeedingWarning.add({
          'packageName': packageName,
          'limitMinutes': limitMinutes,
          'usagePercentage': percentage,
          'todayUsageMillis': getTodayUsage(packageName),
        });
      }
    }
    
    return appsNeedingWarning;
  }
}