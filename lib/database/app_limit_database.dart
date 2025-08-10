import 'package:hive_flutter/hive_flutter.dart';

class AppLimitDatabase {
  List appLimits = [];

  final _myBox = Hive.box("mybox");

  void createInitialData() {
    appLimits = [
      ["Instagram", 30]
    ];
  }

  // Load data from database
  void loadData(){
    appLimits = _myBox.get("APPLIMITS");
  }

  // Update Database
  void updateDatabase() async {
   await _myBox.put("APPLIMITS", appLimits);
  }

  Future<void> saveLimit(String packageName, int limitMillis) async {
    int limitMinutes = (limitMillis / 60000).round();

    // Check if app already has a limit set
    bool found = false;
    for (int i = 0; i < appLimits.length; i++) {
      if (appLimits[i][0] == packageName) {
        appLimits[i][1] = limitMinutes; // update limit
        found = true;
        break;
      }
    }

    // If not found, add new entry
    if (!found) {
      appLimits.add([packageName, limitMinutes]);
    }

    updateDatabase();
  }
}