import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rehabit/auth/domain/entities/app_user.dart';
import 'package:rehabit/auth/domain/repos/auth_repo.dart';
import 'package:rehabit/auth/presentation/cubits/auth_state.dart';

class AuthCubit extends Cubit<AuthState>{
  final AuthRepo authRepo;
  AppUser? _currentUser;

  AuthCubit({required this.authRepo}) : super(AuthInitial());

  AppUser get currentUser => _currentUser!;

  Future <void> checkAuth() async {
    print("Checking authentication status...");
    _currentUser = await authRepo.getCurrentUser();
    print("Current user: $_currentUser");
    try {
      if (_currentUser != null) {
        emit(Authenticated(_currentUser!));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      print("Error checking authentication: $e");
    }

    print("Authentication State: $state");

  }

  Future<void> register(String email, String password, String name) async {
    emit(AuthLoading());

    try {
      _currentUser = await authRepo.registerWithEmailAndPassword(email, password, name);
      if (_currentUser != null) {
        emit(Authenticated(_currentUser!));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());

    try {
      _currentUser = await authRepo.loginWithEmailAndPassword(email, password);
      if (_currentUser != null) {
        emit(Authenticated(_currentUser!));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());

    try {
      await authRepo.signOut();
      _currentUser = null;
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
  
}