import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quiz_champ/src/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.displayName,
    required super.email,
    super.photoUrl,
    super.points,
    super.hearts,
    super.subscriptionStatus,
    required super.createdAt,
  });

  factory UserModel.fromGoogleAccount(GoogleSignInAccount account) {
    // Extract display name with better fallback
    String displayName = 'User';
    if (account.displayName != null && account.displayName!.isNotEmpty) {
      displayName = account.displayName!;
    } else {
      // Use email prefix as fallback (e.g., "john.doe" from "john.doe@gmail.com")
      displayName = account.email.split('@')[0];
    }
    
    return UserModel(
      id: account.id,
      displayName: displayName,
      email: account.email,
      photoUrl: account.photoUrl,
      createdAt: DateTime.now(), // Placeholder: In a real app, this would come from the backend
    );
  }

  factory UserModel.fromFirebaseUser(User user) {
    // Extract display name with better fallback
    String displayName = 'User';
    if (user.displayName != null && user.displayName!.isNotEmpty) {
      displayName = user.displayName!;
    } else if (user.email != null) {
      // Use email prefix as fallback (e.g., "john.doe" from "john.doe@gmail.com")
      displayName = user.email!.split('@')[0];
    }
    
    return UserModel(
      id: user.uid,
      displayName: displayName,
      email: user.email ?? '',
      photoUrl: user.photoURL,
      createdAt: DateTime.now(), // Placeholder: In a real app, this would come from the backend
    );
  }

  // Factory method to create a UserModel from a Firestore/Backend map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      displayName: map['displayName'] as String,
      email: map['email'] as String,
      photoUrl: map['photoUrl'] as String?,
      points: map['points'] as int,
      hearts: map['hearts'] as int,
      subscriptionStatus: map['subscriptionStatus'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  // Method to convert a UserModel to a Firestore/Backend map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'points': points,
      'hearts': hearts,
      'subscriptionStatus': subscriptionStatus,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
