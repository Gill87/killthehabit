import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rehabit/auth/presentation/cubits/auth_cubit.dart';
import 'package:rehabit/auth/presentation/cubits/auth_state.dart';
import 'package:rehabit/auth/presentation/pages/login_page.dart';
import 'package:rehabit/auth/presentation/pages/register_page.dart';
import 'package:rehabit/components/loading_screen.dart';
import 'package:rehabit/home_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool showLoginPage = true;

  void togglePage() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => const HomePage(),
          ));
        } else if (state is Unauthenticated) {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => const AuthPage(),
          ));
        } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Authentication error: ${state.message}")),
            );
        } else {
            // Handle other states if necessary
            Navigator.push((context), MaterialPageRoute(
              builder: (context) => const LoadingScreen(),
            ));
        }
      },
      

      child: showLoginPage
          ? LoginPage(togglePage: togglePage)
          : RegisterPage(togglePage: togglePage),
    );
  }
}