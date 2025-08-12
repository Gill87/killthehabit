import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rehabit/auth/presentation/cubits/auth_cubit.dart';
import 'package:rehabit/auth/presentation/cubits/auth_state.dart';
import 'package:rehabit/auth/presentation/pages/auth_page.dart';
import 'package:rehabit/components/loading_screen.dart';
import 'package:rehabit/pages/base_page.dart';
import 'package:rehabit/splash_screen.dart';
import 'package:rehabit/services/android_screen_time_service.dart';

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  bool _showSplashScreen = true;
  bool _hasShownPermissionDialog = false; // Track if we've shown the dialog

  @override
  void initState() {
    super.initState();


    // Show Splash Screen for 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showSplashScreen = false;
        });
      }
    });
  }


  void _showPermissionDialog() {
    if (_hasShownPermissionDialog) return; // Prevent showing multiple times
    
    _hasShownPermissionDialog = true;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Center(
            child: Text(
              'Screen Time Access',
              style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.phone_android,
                size: 64,
                color: Colors.blue,
              ),
              const SizedBox(height: 16),
              Text(
                'To help you reduce screen time, we need access to your usage statistics.',
                style: GoogleFonts.ubuntu(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'This data stays on your device and is never shared.',
                style: GoogleFonts.ubuntu(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Skip for Now'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                if(Platform.isAndroid){
                  await AndroidScreenTimeService.requestPermission();
                }
              },
              child: const Text('Grant Permission'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) async {
        // Handle permission dialog when user becomes authenticated
        if (state is Authenticated && !_showSplashScreen) {
          print("🔍 DEBUG: User authenticated, checking permission...");
          
          // Small delay to ensure UI is ready
          await Future.delayed(const Duration(milliseconds: 300));
          
          if (mounted) {
            bool hasPermission = await AndroidScreenTimeService.hasPermission();
            print("🔍 DEBUG: Has permission: $hasPermission");
            
            if (!hasPermission && !_hasShownPermissionDialog) {
              print("🔍 DEBUG: Showing permission dialog");
              _showPermissionDialog();
            }
          }
        }
        
        // Handle auth errors
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        if (_showSplashScreen) {
          return const SplashScreen();
        }

        // Check the current state of authentication
        if (state is Authenticated) {
          print("Current state: $state");
          return const BasePage();
        } else if (state is Unauthenticated) {
          print("Current state: $state");
          // Reset permission dialog flag when user logs out
          _hasShownPermissionDialog = false;
          return const AuthPage();
        } else if (state is AuthInitial) {
          print("Current state: $state");
          return const AuthPage();
        } else if (state is AuthLoading){
          print("Current state: $state");
          return const LoadingScreen();
        } else {
          print("Current state: $state");
          return const AuthPage();
        }
      },
    );
  }
}