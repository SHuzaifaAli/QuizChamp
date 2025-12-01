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
    this.stats,
  });

  final Map<String, dynamic>? stats;

  // factory UserModel.fromGoogleAccount(GoogleSignInAccount account) {
  //   // Extract display name with better fallback
  //   String displayName = 'User';
  //   if (account.displayName != null && account.displayName!.isNotEmpty) {
  //     displayName = account.displayName!;
  //   } else {
  //     // Use email prefix as fallback (e.g., "john.doe" from "john.doe@gmail.com")
  //     displayName = account.email.split('@')[0];
  //   }
  //
  //   return UserModel(
  //     id: account.id,
  //     displayName: displayName,
  //     email: account.email,
  //     photoUrl: account.photoUrl,
  //     createdAt: DateTime.now(),
  //   );
  // }

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
      createdAt: DateTime.now(),
    );
  }

  // Factory method to create a UserModel from a Firestore/Backend map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['uid'] as String? ?? map['id'] as String, // Handle both 'uid' and 'id'
      displayName: map['displayName'] as String,
      email: map['email'] as String,
      photoUrl: map['photoUrl'] as String?,
      points: (map['points'] as num?)?.toInt() ?? 0,
      hearts: (map['hearts'] as num?)?.toInt() ?? 5,
      subscriptionStatus: map['subscriptionStatus'] as String? ?? 'free',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      stats: map['stats'] as Map<String, dynamic>?,
    );
  }

  // Method to convert a UserModel to a Firestore/Backend map
  @override
  Map<String, dynamic> toMap() {
    return {
      'uid': id, // Use 'uid' to match Firestore rules
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'points': points,
      'hearts': hearts,
      'subscriptionStatus': subscriptionStatus,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // CopyWith method for creating modified copies
  UserModel copyWith({
    String? id,
    String? displayName,
    String? email,
    String? photoUrl,
    int? points,
    int? hearts,
    String? subscriptionStatus,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      points: points ?? this.points,
      hearts: hearts ?? this.hearts,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
