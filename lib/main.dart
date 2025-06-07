import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:rehabit/firebase_options.dart';
import 'package:rehabit/my_app.dart';

void main() async {
  // Ensure that plugin services are initialized before using any Firebase services.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with the default options for the current platform.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Run the app after Firebase has been initialized.
  runApp(MyApp());
}
