import 'package:equatable/equatable.dart';

class LeaderboardEntity extends Equatable {
  final String userId;
  final String displayName;
  final String? photoUrl;
  final int totalPoints;
  final int totalQuizzes;
  final double accuracyPercentage;
  final int currentStreak;
  final int longestStreak;
  final int rank;

  const LeaderboardEntity({
    required this.userId,
    required this.displayName,
    this.photoUrl,
    required this.totalPoints,
    required this.totalQuizzes,
    required this.accuracyPercentage,
    required this.currentStreak,
    required this.longestStreak,
    required this.rank,
  });

  @override
  List<Object?> get props => [
        userId,
        displayName,
        photoUrl,
        totalPoints,
        totalQuizzes,
        accuracyPercentage,
        currentStreak,
        longestStreak,
        rank,
      ];
}
