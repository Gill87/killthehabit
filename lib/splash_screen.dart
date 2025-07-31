import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rehabit/auth/presentation/cubits/auth_cubit.dart';
import 'package:rehabit/auth/presentation/cubits/auth_state.dart';
import 'package:rehabit/auth/presentation/pages/auth_page.dart';
import 'package:rehabit/home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 2), () {
      final authState = context.read<AuthCubit>().state;

      if(authState is Authenticated) {
        // User is authenticated, navigate to home page
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => const HomePage(),
        ));
      } 
      
      else if(authState is AuthLoading) {
        print("Auth Loaddinngg");
        
        // Show loading indicator
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => const Center(child: CircularProgressIndicator()),
        ));
      }

      else {
        // User is not authenticated, navigate to login page
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => const AuthPage(),
        ));
      } 

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "Kill the Habit",
          style: GoogleFonts.ubuntu(
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}