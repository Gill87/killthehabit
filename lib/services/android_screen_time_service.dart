import 'package:flutter/services.dart';

class AndroidScreenTimeService {
  static const platform = MethodChannel('screen_time_channel');
  
  // Check if we have permission
  static Future<bool> hasPermission() async {
    try {
      return await platform.invokeMethod('hasUsagePermission');
    } catch (e) {
      print("Error checking permission: $e");
      return false;
    }
  }
  
  // Request permission (opens Android settings)
  static Future<void> requestPermission() async {
    try {
      await platform.invokeMethod('requestUsagePermission');
    } catch (e) {
      print("Error requesting permission: $e");
    }
  }
  
  // Get the actual screen time data
  static Future<List<Map<String, dynamic>>> getUsageStats() async {
    try {
      final dynamic result = await platform.invokeMethod('getAppUsageStats');
      if (result is List) {
        return List<Map<String, dynamic>>.from(
          result.map((item) => Map<String, dynamic>.from(item))
        );
      }
      return [];
    } catch (e) {
      print("Error getting usage stats: $e");
      return [];
    }
  }

  // Get total device screen time
  static Future<int> getTotalScreenTime() async {
    try {
      final int result = await platform.invokeMethod('getTotalScreenTime');
      return result;
    } catch (e) {
      print("Error getting total screen time: $e");
      return 0;
    }
  }

  // Helper method to format time
  static String formatTime(int milliseconds) {
    final minutes = milliseconds ~/ (1000 * 60);
    if (minutes < 60) {
      return '${minutes}m';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '${hours}h';
      }
      return '${hours}h ${remainingMinutes}m';
    }
  }

  // Helper method to get friendly app names
  static String getFriendlyAppName(String packageName) {
    switch (packageName) {
      case 'com.facebook.katana':
        return 'Facebook';
      case 'com.facebook.orca':
        return 'Messenger';
      case 'com.instagram.android':
        return 'Instagram';
      case 'com.whatsapp':
        return 'WhatsApp';
      case 'com.google.android.youtube':
        return 'YouTube';
      case 'com.google.android.gms':
        return 'Google Play Services';
      case 'com.android.chrome':
        return 'Chrome';
      case 'com.spotify.music':
        return 'Spotify';
      case 'com.netflix.mediaclient':
        return 'Netflix';
      case 'com.snapchat.android':
        return 'Snapchat';
      case 'com.twitter.android':
        return 'Twitter';
      case 'com.zhiliaoapp.musically':
        return 'TikTok';
      case 'com.discord':
        return 'Discord';
      case 'com.samsung.android.messaging':
        return 'Messages';
      case 'com.samsung.android.dialer':
        return 'Phone';
      case 'com.sec.android.gallery3d':
        return 'Gallery';
      // Add more mappings as needed
      default:
        // Extract app name from package (last part after final dot)
        String appName = packageName.split('.').last;
        // Capitalize first letter
        return appName.isNotEmpty 
            ? appName[0].toUpperCase() + appName.substring(1)
            : packageName;
    }
  }
}