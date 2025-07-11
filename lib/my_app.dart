import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rehabit/app_root.dart';
import 'package:rehabit/auth/data/firebase_auth_repo.dart';
import 'package:rehabit/auth/presentation/cubits/auth_cubit.dart';
import 'package:rehabit/themes/light_mode.dart';

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final firebaseAuthRepo = FirebaseAuthRepo();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit> (
          create: (context) => AuthCubit(authRepo: firebaseAuthRepo)..checkAuth()
        ),

      ],
      child: MaterialApp(
        title: 'Kill The Habit',
        debugShowCheckedModeBanner: false,
        home: const AppRoot(),
        theme: lightMode(),
      ),
    );
  }
}