import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quiz_champ/src/data/models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  UserService({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  }) : _firestore = firestore,
       _auth = auth;

  Future<void> ensureUserDocumentExists() async {
    log("📝 [UserService] Checking if user document exists...");
    
    final user = _auth.currentUser;
    if (user == null) {
      log("❌ [UserService] No authenticated user found");
      return;
    }

    log("👤 [UserService] Current user: ${user.uid}, Email: ${user.email}");
    final userDoc = _firestore.collection('users').doc(user.uid);
    final docSnapshot = await userDoc.get();

    if (!docSnapshot.exists) {
      log("📋 [UserService] User document does not exist, creating new document...");
      // Create user document for first-time users
      final userModel = UserModel.fromFirebaseUser(user);
      
      final userData = {
        'uid': userModel.id, // Use 'uid' to match Firestore rules
        'email': userModel.email,
        'displayName': userModel.displayName,
        'photoUrl': userModel.photoUrl,
        'points': userModel.points,
        'hearts': userModel.hearts,
        'subscriptionStatus': userModel.subscriptionStatus,
        'createdAt': Timestamp.now(),
        'lastLoginAt': Timestamp.now(),
        'isOnline': true,
        'friends': [],
        'stats': {
          'totalPoints': 0,
          'quizzesCompleted': 0,
          'correctAnswers': 0,
          'averageScore': 0.0,
        },
        'visibility': 'public',
      };
      
      log("💾 [UserService] Writing user data to Firestore: ${userData.keys.toList()}");
      await userDoc.set(userData);
      log("✅ [UserService] User document created successfully");
    } else {
      log("🔄 [UserService] User document exists, updating last login...");
      // Update last login time
      await userDoc.update({
        'lastLoginAt': Timestamp.now(),
        'isOnline': true,
      });
      log("✅ [UserService] User document updated successfully");
    }
  }

  Future<void> updateUserHearts(int hearts) async {
    final user = _auth.currentUser;
    if (user == null) {
      log("❌ [UserService] No authenticated user found for hearts update");
      return;
    }

    try {
      log("💔 [UserService] Updating hearts to $hearts for user ${user.uid}");
      await _firestore.collection('users').doc(user.uid).update({
        'hearts': hearts,
        'updatedAt': Timestamp.now(),
      });
      log("✅ [UserService] Hearts updated successfully in Firebase");
    } catch (e) {
      log("❌ [UserService] Failed to update hearts: $e");
      rethrow;
    }
  }

  Future<void> updateUserPoints(int points) async {
    final user = _auth.currentUser;
    if (user == null) {
      log("❌ [UserService] No authenticated user found for points update");
      return;
    }

    try {
      log("🏆 [UserService] Updating points to $points for user ${user.uid}");
      await _firestore.collection('users').doc(user.uid).update({
        'points': points,
        'updatedAt': Timestamp.now(),
      });
      log("✅ [UserService] Points updated successfully in Firebase");
    } catch (e) {
      log("❌ [UserService] Failed to update points: $e");
      rethrow;
    }
  }

  Future<void> updateUserStats({
    required int totalPoints,
    required int quizzesCompleted,
    required int correctAnswers,
    required double averageScore,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      log("❌ [UserService] No authenticated user found for stats update");
      return;
    }

    try {
      log("📊 [UserService] Updating stats for user ${user.uid}");
      await _firestore.collection('users').doc(user.uid).update({
        'points': totalPoints,
        'stats': {
          'totalPoints': totalPoints,
          'quizzesCompleted': quizzesCompleted,
          'correctAnswers': correctAnswers,
          'averageScore': averageScore,
        },
        'updatedAt': Timestamp.now(),
      });
      log("✅ [UserService] Stats updated successfully in Firebase");
    } catch (e) {
      log("❌ [UserService] Failed to update stats: $e");
      rethrow;
    }
  }

  Future<UserModel?> getCurrentUserData() async {
    final user = _auth.currentUser;
    if (user == null) {
      log("❌ [UserService] No authenticated user found");
      return null;
    }

    try {
      log("📖 [UserService] Fetching user data for ${user.uid}");
      final docSnapshot = await _firestore.collection('users').doc(user.uid).get();
      
      if (docSnapshot.exists) {
        final userData = docSnapshot.data()!;
        log("✅ [UserService] User data fetched successfully");
        return UserModel.fromMap(userData);
      } else {
        log("⚠️ [UserService] User document does not exist");
        return null;
      }
    } catch (e) {
      log("❌ [UserService] Failed to fetch user data: $e");
      return null;
    }
  }

  Future<void> updateUserOffline() async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).update({
      'isOnline': false,
    });
  }
}
