import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:rehabit/firebase_options.dart';
import 'package:rehabit/home_page.dart';

void main() async {
  // Ensure that plugin services are initialized before using any Firebase services.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with the default options for the current platform.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Run the app after Firebase has been initialized.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kill The Habit',
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      
    );
  }

}
