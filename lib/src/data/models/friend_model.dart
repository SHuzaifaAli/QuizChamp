import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/friend_entity.dart';

class FriendModel extends Friend {
  const FriendModel({
    required super.id,
    required super.userId,
    required super.displayName,
    super.photoUrl,
    super.email,
    required super.friendsSince,
    required super.isOnline,
    required super.lastSeen,
    required super.status,
    required super.stats,
  });

  factory FriendModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FriendModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      displayName: data['displayName'] ?? '',
      photoUrl: data['photoUrl'],
      email: data['email'],
      friendsSince: (data['friendsSince'] as Timestamp).toDate(),
      isOnline: data['isOnline'] ?? false,
      lastSeen: (data['lastSeen'] as Timestamp).toDate(),
      status: FriendshipStatus.values.firstWhere(
        (e) => e.toString() == 'FriendshipStatus.${data['status']}',
        orElse: () => FriendshipStatus.accepted,
      ),
      stats: SocialStatsModel.fromMap(data['stats'] ?? {}),
    );
  }

  factory FriendModel.fromEntity(Friend friend) {
    return FriendModel(
      id: friend.id,
      userId: friend.userId,
      displayName: friend.displayName,
      photoUrl: friend.photoUrl,
      email: friend.email,
      friendsSince: friend.friendsSince,
      isOnline: friend.isOnline,
      lastSeen: friend.lastSeen,
      status: friend.status,
      stats: friend.stats,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'email': email,
      'friendsSince': Timestamp.fromDate(friendsSince),
      'isOnline': isOnline,
      'lastSeen': Timestamp.fromDate(lastSeen),
      'status': status.toString().split('.').last,
      'stats': SocialStatsModel.fromEntity(stats).toMap(),
    };
  }
}

class SocialStatsModel extends SocialStats {
  const SocialStatsModel({
    required super.totalQuizzes,
    required super.correctAnswers,
    required super.accuracyPercentage,
    required super.currentStreak,
    required super.longestStreak,
    required super.totalPoints,
    required super.lastQuizDate,
  });

  factory SocialStatsModel.fromMap(Map<String, dynamic> map) {
    return SocialStatsModel(
      totalQuizzes: map['totalQuizzes'] ?? 0,
      correctAnswers: map['correctAnswers'] ?? 0,
      accuracyPercentage: (map['accuracyPercentage'] ?? 0.0).toDouble(),
      currentStreak: map['currentStreak'] ?? 0,
      longestStreak: map['longestStreak'] ?? 0,
      totalPoints: map['totalPoints'] ?? 0,
      lastQuizDate: map['lastQuizDate'] != null 
          ? (map['lastQuizDate'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  factory SocialStatsModel.fromEntity(SocialStats stats) {
    return SocialStatsModel(
      totalQuizzes: stats.totalQuizzes,
      correctAnswers: stats.correctAnswers,
      accuracyPercentage: stats.accuracyPercentage,
      currentStreak: stats.currentStreak,
      longestStreak: stats.longestStreak,
      totalPoints: stats.totalPoints,
      lastQuizDate: stats.lastQuizDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalQuizzes': totalQuizzes,
      'correctAnswers': correctAnswers,
      'accuracyPercentage': accuracyPercentage,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'totalPoints': totalPoints,
      'lastQuizDate': Timestamp.fromDate(lastQuizDate),
    };
  }
}