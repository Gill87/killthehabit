import 'package:flutter/services.dart';

class ForegroundService {

  static const platform = MethodChannel('screen_time_channel');

  static Future<void> startService() async {
    await platform.invokeMethod('startForegroundService');
  }

  static Future<void> stopService() async {
    await platform.invokeMethod('stopForegroundService');
  }

}
