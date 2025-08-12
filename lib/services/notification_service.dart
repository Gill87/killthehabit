import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rehabit/services/android_screen_time_service.dart';

class NotificationService {
  final notificationPlugin = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;


  // INITIALIZE
  Future<void> initNotifications() async {

    // If already initialized, return
    if(_isInitialized) return;

    // Android
    const initSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher'); // Default Flutter Logo

    const initSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const initSettings = InitializationSettings(
      android: initSettingsAndroid,
      iOS: initSettingsIOS,
    );

    await notificationPlugin.initialize(initSettings);
  }

  // NOTIFICATION DETAILS
  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_channel_id',
        'Daily Notifications',
        channelDescription: 'Channel for daily notifications',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      ),

      iOS: DarwinNotificationDetails(),

    );
  }

  // WARNING NOTIFICATION DETAILS (for 80% usage warnings)
  NotificationDetails warningNotificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'warning_channel_id',
        'Usage Warning Notifications',
        channelDescription: 'Notifications for app usage warnings',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        color: Color(0xFFFF9800), // Orange color for warnings
        colorized: true,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  // LIMIT EXCEEDED NOTIFICATION DETAILS
  NotificationDetails limitExceededNotificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'limit_exceeded_channel_id',
        'Limit Exceeded Notifications',
        channelDescription: 'Notifications when app usage limit is exceeded',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        color: Color(0xFFF44336), // Red color for limit exceeded
        colorized: true,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }


 // SHOW 80% USAGE WARNING NOTIFICATION
  Future<void> showUsageWarningNotification({
    required String packageName,
    required double usagePercentage,
    required int limitMinutes,
    required int todayUsageMinutes,
  }) async {
    String appName = AndroidScreenTimeService.getFriendlyAppName(packageName);
    String usageTime = AndroidScreenTimeService.formatTime(todayUsageMinutes * 60 * 1000);
    String limitTime = AndroidScreenTimeService.formatTime(limitMinutes * 60 * 1000);
    
    int notificationId = packageName.hashCode % 1000000; // Generate unique ID based on package name
    
    await notificationPlugin.show(
      notificationId,
      '⚠️ Usage Warning: $appName',
      'You\'ve used $usageTime of your $limitTime limit (${usagePercentage.toInt()}%). Consider taking a break!',
      warningNotificationDetails(),
    );
  }
  
  // SHOW LIMIT EXCEEDED NOTIFICATION
  Future<void> showLimitExceededNotification({
    required String packageName,
    required int limitMinutes,
    required int todayUsageMinutes,
  }) async {
    String appName = AndroidScreenTimeService.getFriendlyAppName(packageName);
    String usageTime = AndroidScreenTimeService.formatTime(todayUsageMinutes * 60 * 1000);
    String limitTime = AndroidScreenTimeService.formatTime(limitMinutes * 60 * 1000);
    
    int notificationId = (packageName + '_exceeded').hashCode % 1000000;
    
    await notificationPlugin.show(
      notificationId,
      '🚫 Limit Exceeded: $appName',
      'You\'ve exceeded your limit! Used: $usageTime / Limit: $limitTime. Time for a digital detox!',
      limitExceededNotificationDetails(),
    );
  }
  
  // SHOW DAILY SUMMARY NOTIFICATION
  Future<void> showDailySummaryNotification({
    required int totalScreenTimeMillis,
    required int totalAppsWithLimits,
    required int appsOverLimit,
  }) async {
    String totalTime = AndroidScreenTimeService.formatTime(totalScreenTimeMillis);
    
    String body;
    if (appsOverLimit == 0) {
      body = 'Great job! You stayed within your limits today. Total screen time: $totalTime';
    } else {
      body = 'You exceeded limits on $appsOverLimit out of $totalAppsWithLimits apps. Total screen time: $totalTime';
    }
    
    await notificationPlugin.show(
      999999, // Fixed ID for daily summary
      '📊 Daily Usage Summary',
      body,
      notificationDetails(),
    );
  }
  
  // CANCEL SPECIFIC NOTIFICATION
  Future<void> cancelNotification(int id) async {
    await notificationPlugin.cancel(id);
  }
  
  // CANCEL ALL NOTIFICATIONS
  Future<void> cancelAllNotifications() async {
    await notificationPlugin.cancelAll();
  }
  
  // CHECK IF NOTIFICATIONS ARE ENABLED
  Future<bool> areNotificationsEnabled() async {
    final androidImplementation = notificationPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      return await androidImplementation.areNotificationsEnabled() ?? false;
    }
    return true; // Assume enabled for iOS
  }
}