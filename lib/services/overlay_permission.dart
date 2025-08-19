import 'package:flutter/services.dart';

class OverlayPermission {
  static const platform = MethodChannel('screen_time_channel');

  static Future<void> requestOverlayPermission() async {
    try {
      await platform.invokeMethod('requestOverlayPermission');
    } catch (e) {
      print("Error requesting overlay: $e");
    }
  }

  static Future<bool> hasOverlayPermission() async {
    try {
      final bool hasPermission = await platform.invokeMethod('hasOverlayPermission');
      return hasPermission;
    } catch (e) {
      print("Error checking overlay permission: $e");
      return false;
    }
  }
}