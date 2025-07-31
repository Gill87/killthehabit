import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rehabit/auth/presentation/cubits/auth_cubit.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});


  void getIosScreenTime() {
    // Implement iOS screen time retrieval logic
  }

  void getAndroidScreenTime() {
    // Implement Android screen time retrieval logic
  }

  @override
  Widget build(BuildContext context) {
    
    // Function to handle logout
    void logout(){
      AuthCubit authCubit = context.read<AuthCubit>();
      authCubit.logout();
    }

    return Scaffold(

      // Start App Bar
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
      // End App Bar

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => getIosScreenTime(),
              child: const Text('Get iOS Screen Time'),
            ),

            ElevatedButton(
              onPressed: () => getAndroidScreenTime(),
              child: const Text('Get Android Screen Time'),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Dashboard',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Progress',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}