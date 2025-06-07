import 'package:rehabit/auth/domain/entities/app_user.dart';

abstract class AuthRepo {
  Future<AppUser?> loginWithEmailAndPassword (String email, String password);

  Future<AppUser?> registerWithEmailAndPassword (String email, String password, String name);

  Future<void> signOut();

  Future<bool> isSignedIn();

  Future<AppUser?> getCurrentUser();
}