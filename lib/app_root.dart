import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rehabit/auth/presentation/cubits/auth_cubit.dart';
import 'package:rehabit/auth/presentation/cubits/auth_state.dart';
import 'package:rehabit/auth/presentation/pages/auth_page.dart';
import 'package:rehabit/components/loading_screen.dart';
import 'package:rehabit/home_page.dart';

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  bool _showSplashScreen = true;

  @override
  void initState() {
    super.initState();

    // Show Splash Screen for 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _showSplashScreen = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer <AuthCubit, AuthState>(
      builder: (context, state) {
        if (_showSplashScreen) {
          return const Scaffold(body: Center(child: Text("Kill the Habit")));
        }

        // Check the current state of authentication
        if (state is Authenticated) {
          print("Current state: $state");
          return const HomePage();
        } else if (state is Unauthenticated) {
          print("Current state: $state");
          return const AuthPage();
        } else if(state is AuthInitial){
          print("Current state: $state");
          return const AuthPage();
        }
        else {
          print("Current state: $state");
          return const LoadingScreen();
        } 
      }, 
      listener: (context, state){
        if(state is AuthError){
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AuthPage()));
          
          // Show an error message using a SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      }
    );
  }
}