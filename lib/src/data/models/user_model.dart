import 'package:google_sign_in/google_sign_in.dart';
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
    return UserModel(
      id: account.id,
      displayName: account.displayName ?? 'User',
      email: account.email,
      photoUrl: account.photoUrl,
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
