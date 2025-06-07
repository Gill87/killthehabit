import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rehabit/auth/presentation/cubits/auth_cubit.dart';
import 'package:rehabit/components/large_text_field.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? togglePage;

  const RegisterPage({
    required this.togglePage,
    super.key
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

// Controllers for email and password input fields

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  void register(){
    if(passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match!"))
      );
      return;
    } else {
      context.read<AuthCubit>().register(emailController.text, passwordController.text, nameController.text);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
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

                LargeTextField(controller: nameController, hintText: "Name"),
                LargeTextField(controller: emailController, hintText: "Email"),
                LargeTextField(controller: passwordController, hintText: "Password"),
                LargeTextField(controller: confirmPasswordController, hintText: "Confirm Password"),
                
                const SizedBox(height: 20),
        
                ElevatedButton(
                  onPressed: register,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    "Sign Up", 
                    style: GoogleFonts.ubuntu(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                TextButton(
                  onPressed: widget.togglePage, 
                  child: Text(
                    "Already have an account? Login",
                    style: GoogleFonts.ubuntu(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}