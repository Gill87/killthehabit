import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rehabit/auth/presentation/cubits/auth_cubit.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});


  @override
  Widget build(BuildContext context) {
    
    // Function to handle logout
    void logout(){
      AuthCubit authCubit = context.read<AuthCubit>();
      authCubit.logout();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Kill the Habit',
          style: GoogleFonts.ubuntu(fontSize: 24),
        ),

        centerTitle: true,
        
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => logout(),
          ),
        ],
      ),
      body: const Center(
        child: Text('Build Awesome-Sauce Habits!'),
      ),
    );
  }
}