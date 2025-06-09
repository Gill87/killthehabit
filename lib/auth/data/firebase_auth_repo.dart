import 'package:google_sign_in/google_sign_in.dart';
import 'package:rehabit/auth/domain/entities/app_user.dart';
import 'package:rehabit/auth/domain/repos/auth_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthRepo implements AuthRepo {

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  Future<AppUser?> loginWithEmailAndPassword(String email, String password) async {
    try {
      // Sign in with email and password
      UserCredential userCredential = await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);

      // Fetch user data from Firestore
      DocumentSnapshot userDoc = await firebaseFirestore.collection('users').doc(userCredential.user?.uid).get();

      // Record user
      AppUser user = AppUser(
        email: email, 
        uid: userCredential.user!.uid, 
        name: userDoc['name']
      );

      // Return the user object
      return user;

    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<AppUser?> registerWithEmailAndPassword(String email, String password, String name) async {
    // Implement Firebase registration logic here
    try {
      UserCredential userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // If registration is successful, save user data to Firestore
      await firebaseFirestore.collection('users').doc(userCredential.user?.uid).set({
        'email': email,
        'name': name,
      });

      return AppUser(
        uid: userCredential.user?.uid ?? '',
        email: email,
        name: name,
      );

    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    // Implement Firebase sign-out logic here
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }
  
  @override
  Future<AppUser?> getCurrentUser() async {
    // Get Person Currently Logged In
    final firebaseUser = firebaseAuth.currentUser;

    // check null
    if (firebaseUser == null) {
      return null;
    }

    // Fetch user document from firestore
    DocumentSnapshot userDoc = await firebaseFirestore.collection('users').doc(firebaseUser.uid).get();

    if (!userDoc.exists) {
      print("No such user document for uid");
      return null; // Or handle however you want
    }

    return AppUser(
      uid: firebaseUser.uid,
      email: firebaseUser.email!,
      name: userDoc['name'],
    );
  }

  @override
  Future signInWithGoogle() async {

    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    return await firebaseAuth.signInWithCredential(credential);
  }
  
  @override
  bool isSignedIn() {
    return (firebaseAuth.currentUser != null);
  }

}