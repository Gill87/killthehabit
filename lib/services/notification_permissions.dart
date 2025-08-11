import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationPermissions {

  static Future<bool> checkNotificationPermission() async {
    var status = await Permission.notification.status;
    print("Notification permission status: $status");
    return status.isGranted;
  }

  static Future<void> requestNotificationPermission(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Enable Notifications"),
          content: const Text(
            "We’d like to send you reminders and updates to help you stay on track. "
            "Please enable notifications for the best experience.",
          ),
          actions: [
            TextButton(
              child: const Text("No, thanks"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text("Enable"),
              onPressed: () async {
                Navigator.of(context).pop();
                await Permission.notification.request();
              },
            ),
          ],
        );
      },
    );
  }
}