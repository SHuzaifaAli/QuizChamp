import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quiz_champ/src/core/error/failures.dart';
import 'package:quiz_champ/src/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithGoogle();
  Future<void> signOut();
  Future<UserModel?> getSignedInUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
  });

  @override
  Future<UserModel?> getSignedInUser() async {
    try {
      log("🔍 [AuthRemoteDataSource] Checking current Firebase user...");
      final user = firebaseAuth.currentUser;

      if (user != null) {
        log("✅ [AuthRemoteDataSource] Found authenticated user: ${user.uid}, Email: ${user.email}");
        log("👤 [AuthRemoteDataSource] User details: ${user.displayName}, PhotoURL: ${user.photoURL}");
        return UserModel.fromFirebaseUser(user);
      } else {
        log("❌ [AuthRemoteDataSource] No authenticated user found");
        return null;
      }
    } catch (e, stackTrace) {
      log("💥 [AuthRemoteDataSource] Error getting signed-in user: ${e.toString()}");
      log("📚 [AuthRemoteDataSource] Stack trace: $stackTrace");
      throw AuthFailure(message: e.toString());
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      print(
          "🔥🔥🔥 [AuthRemoteDataSource] Starting Firebase Google Sign-In flow...");
      log("🔥 [AuthRemoteDataSource] Starting Firebase Google Sign-In flow...");

      // Create GoogleAuthProvider for Firebase Auth
      print("� [AuthRemoteDataSource] Creating GoogleAuthProvider...");
      log("� [AuthRemoteDataSource] Creating GoogleAuthProvider...");
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();

      // Set custom parameters for Android
      // googleProvider.addCustomParameter('prompt', 'select_account');
      // googleProvider.setCustomParameters({
      //   'login_hint': '', // Can be set to user's email if known
      // });

      // Sign in with Firebase using Google provider
      print(
          "� [AuthRemoteDataSource] Signing into Firebase with Google provider...");
      log("� [AuthRemoteDataSource] Signing into Firebase with Google provider...");
      final UserCredential userCredential =
          await firebaseAuth.signInWithProvider(googleProvider);

      if (userCredential.user == null) {
        print("❌ [AuthRemoteDataSource] No user returned from Firebase Auth");
        log("❌ [AuthRemoteDataSource] No user returned from Firebase Auth");
        throw AuthFailure(message: "No user returned from authentication");
      }

      print("✅ [AuthRemoteDataSource] Firebase Google Sign-In successful!");
      print(
          "� [AuthRemoteDataSource] User: ${userCredential.user!.displayName}, Email: ${userCredential.user!.email}");
      print("🆔 [AuthRemoteDataSource] UID: ${userCredential.user!.uid}");

      log("✅ [AuthRemoteDataSource] Firebase Google Sign-In successful!");
      log("👤 [AuthRemoteDataSource] User: ${userCredential.user!.displayName}, Email: ${userCredential.user!.email}");
      log("🆔 [AuthRemoteDataSource] UID: ${userCredential.user!.uid}");

      return UserModel.fromFirebaseUser(userCredential.user!);
    } catch (e, stackTrace) {
      print(
          "💥💥💥 [AuthRemoteDataSource] Error during Firebase Google Sign-In: ${e.toString()}");
      log("💥 [AuthRemoteDataSource] Error during Firebase Google Sign-In: ${e.toString()}");
      print("📚📚📚 [AuthRemoteDataSource] Stack trace: $stackTrace");
      log("📚 [AuthRemoteDataSource] Stack trace: $stackTrace");

      // Check for user cancellation
      if (e.toString().contains('user-cancelled') ||
          e.toString().contains('cancelled')) {
        print("❌ [AuthRemoteDataSource] User cancelled authentication");
        log("❌ [AuthRemoteDataSource] User cancelled authentication");
        throw UserCancelledAuthFailure();
      }

      throw AuthFailure(message: e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      print("👋 [AuthRemoteDataSource] Signing out from Firebase...");
      log("👋 [AuthRemoteDataSource] Signing out from Firebase...");
      await firebaseAuth.signOut();
      print("✅ [AuthRemoteDataSource] Sign out successful");
      log("✅ [AuthRemoteDataSource] Sign out successful");
    } catch (e, stackTrace) {
      print("💥 [AuthRemoteDataSource] Error during sign out: ${e.toString()}");
      log("💥 [AuthRemoteDataSource] Error during sign out: ${e.toString()}");
      log("📚 [AuthRemoteDataSource] Stack trace: $stackTrace");
      throw AuthFailure(message: e.toString());
    }
  }
}
