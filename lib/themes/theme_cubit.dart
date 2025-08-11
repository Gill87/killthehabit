import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rehabit/themes/dark_mode.dart';
import 'package:rehabit/themes/light_mode.dart';

class ThemeCubit extends Cubit<ThemeData> {

  // Variable
  bool _isDarkMode = false;

  // Getter
  bool get isDarkMode => _isDarkMode; 
  
  ThemeCubit() : super(lightMode);

  void toggleTheme(){
    _isDarkMode = !_isDarkMode;

    if(_isDarkMode){
      emit(darkMode);
    } else {
      emit(lightMode);
    }
  }
}