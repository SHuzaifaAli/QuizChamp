import 'package:equatable/equatable.dart';

enum FriendshipStatus {
  pending,
  accepted,
  blocked,
}

class Friend extends Equatable {
  final String id;
  final String userId;
  final String displayName;
  final String? photoUrl;
  final String? email;
  final DateTime friendsSince;
  final bool isOnline;
  final DateTime lastSeen;
  final FriendshipStatus status;
  final SocialStats stats;

  const Friend({
    required this.id,
    required this.userId,
    required this.displayName,
    this.photoUrl,
    this.email,
    required this.friendsSince,
    required this.isOnline,
    required this.lastSeen,
    required this.status,
    required this.stats,
  });

  Friend copyWith({
    String? id,
    String? userId,
    String? displayName,
    String? photoUrl,
    String? email,
    DateTime? friendsSince,
    bool? isOnline,
    DateTime? lastSeen,
    FriendshipStatus? status,
    SocialStats? stats,
  }) {
    return Friend(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      email: email ?? this.email,
      friendsSince: friendsSince ?? this.friendsSince,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      status: status ?? this.status,
      stats: stats ?? this.stats,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        displayName,
        photoUrl,
        email,
        friendsSince,
        isOnline,
        lastSeen,
        status,
        stats,
      ];
}

class SocialStats extends Equatable {
  final int totalQuizzes;
  final int correctAnswers;
  final double accuracyPercentage;
  final int currentStreak;
  final int longestStreak;
  final int totalPoints;
  final DateTime lastQuizDate;

  const SocialStats({
    required this.totalQuizzes,
    required this.correctAnswers,
    required this.accuracyPercentage,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalPoints,
    required this.lastQuizDate,
  });

  SocialStats copyWith({
    int? totalQuizzes,
    int? correctAnswers,
    double? accuracyPercentage,
    int? currentStreak,
    int? longestStreak,
    int? totalPoints,
    DateTime? lastQuizDate,
  }) {
    return SocialStats(
      totalQuizzes: totalQuizzes ?? this.totalQuizzes,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      accuracyPercentage: accuracyPercentage ?? this.accuracyPercentage,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalPoints: totalPoints ?? this.totalPoints,
      lastQuizDate: lastQuizDate ?? this.lastQuizDate,
    );
  }

  @override
  List<Object?> get props => [
        totalQuizzes,
        correctAnswers,
        accuracyPercentage,
        currentStreak,
        longestStreak,
        totalPoints,
        lastQuizDate,
      ];
}