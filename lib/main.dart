import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rehabit/firebase_options.dart';
import 'package:rehabit/my_app.dart';

void main() async {
  // Ensure that plugin services are initialized before using any Firebase services.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with the default options for the current platform.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Hive and Open Hive Box
  await Hive.initFlutter();
  await Hive.openBox('mybox');
  
  // Run the app after Firebase has been initialized.
  runApp(MyApp());
}
