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
    final user = _auth.currentUser;
    if (user == null) return;

    final userDoc = _firestore.collection('users').doc(user.uid);
    final docSnapshot = await userDoc.get();

    if (!docSnapshot.exists) {
      // Create user document for first-time users
      final userModel = UserModel.fromFirebaseUser(user);
      await userDoc.set({
        'id': userModel.id, // Use 'id' instead of 'uid' to match UserModel.fromMap()
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
      });
    } else {
      // Update last login time
      await userDoc.update({
        'lastLoginAt': Timestamp.now(),
        'isOnline': true,
      });
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
