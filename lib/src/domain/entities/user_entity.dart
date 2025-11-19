import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String displayName;
  final String email;
  final String? photoUrl;
  final int points;
  final int hearts;
  final String subscriptionStatus; // e.g., 'free', 'premium'
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.displayName,
    required this.email,
    this.photoUrl,
    this.points = 0,
    this.hearts = 5,
    this.subscriptionStatus = 'free',
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        displayName,
        email,
        photoUrl,
        points,
        hearts,
        subscriptionStatus,
        createdAt,
      ];
}
