import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rehabit/auth/presentation/cubits/auth_cubit.dart';
import 'package:rehabit/components/large_text_field.dart';

class LoginPage extends StatefulWidget {
  final void Function()? togglePage;

  const LoginPage({
    super.key,
    required this.togglePage,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}


class _LoginPageState extends State<LoginPage> {

  // Controllers for email and password input fields
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void login(){
    // Get the AuthCubit from the context
    final authCubit = context.read<AuthCubit>();

    // Call the login method from AuthCubit with email and password
    authCubit.login(emailController.text, passwordController.text);

    // Clear the input fields after login attempt
    emailController.clear();
    passwordController.clear();
  }

  @override
  void dispose() { 
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 100),
                Text(
                  "Kill the Habit",
                  style: GoogleFonts.ubuntu(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        
                const SizedBox(height: 20),
        
                LargeTextField(controller: emailController, hintText: "Email"),
                LargeTextField(controller: passwordController, hintText: "Password"),
        
                const SizedBox(height: 20),
        
                ElevatedButton(
                  onPressed: login,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    "Login", 
                    style: GoogleFonts.ubuntu(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: widget.togglePage,
                      child: Text(
                        "Create an account",
                        style: GoogleFonts.ubuntu(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    TextButton(
                      onPressed: ()=>{},
                      child: Text(
                        "Forgot Password?",
                        style: GoogleFonts.ubuntu(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}