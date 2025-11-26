import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quiz_champ/src/domain/entities/leaderboard_entity.dart';

abstract class LeaderboardRemoteDataSource {
  Future<List<LeaderboardEntity>> getGlobalLeaderboard({int limit = 50});
  Future<List<LeaderboardEntity>> getFriendsLeaderboard(String userId, {int limit = 50});
  Future<LeaderboardEntity?> getUserRank(String userId);
}

class LeaderboardRemoteDataSourceImpl implements LeaderboardRemoteDataSource {
  final FirebaseFirestore firestore;

  LeaderboardRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<LeaderboardEntity>> getGlobalLeaderboard({int limit = 50}) async {
    try {
      final snapshot = await firestore
          .collection('users')
          .where('stats.totalPoints', isGreaterThan: 0)
          .orderBy('stats.totalPoints', descending: true)
          .limit(limit)
          .get();

      final leaderboard = <LeaderboardEntity>[];
      int rank = 1;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final stats = data['stats'] as Map<String, dynamic>? ?? {};

        leaderboard.add(LeaderboardEntity(
          userId: data['uid'] ?? '',
          displayName: data['displayName'] ?? '',
          photoUrl: data['photoURL'],
          totalPoints: stats['totalPoints'] ?? 0,
          totalQuizzes: stats['totalQuizzes'] ?? 0,
          accuracyPercentage: (stats['accuracyPercentage'] ?? 0).toDouble(),
          currentStreak: stats['currentStreak'] ?? 0,
          longestStreak: stats['longestStreak'] ?? 0,
          rank: rank++,
        ));
      }

      return leaderboard;
    } catch (e) {
      throw Exception('Failed to get global leaderboard: $e');
    }
  }

  @override
  Future<List<LeaderboardEntity>> getFriendsLeaderboard(String userId, {int limit = 50}) async {
    try {
      final userDoc = await firestore.collection('users').doc(userId).get();
      final userData = userDoc.data();
      final friends = List<String>.from(userData?['friends'] ?? []);

      if (friends.isEmpty) {
        return [];
      }

      final snapshot = await firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: friends)
          .orderBy('stats.totalPoints', descending: true)
          .limit(limit)
          .get();

      final leaderboard = <LeaderboardEntity>[];
      int rank = 1;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final stats = data['stats'] as Map<String, dynamic>? ?? {};

        leaderboard.add(LeaderboardEntity(
          userId: data['uid'] ?? '',
          displayName: data['displayName'] ?? '',
          photoUrl: data['photoURL'],
          totalPoints: stats['totalPoints'] ?? 0,
          totalQuizzes: stats['totalQuizzes'] ?? 0,
          accuracyPercentage: (stats['accuracyPercentage'] ?? 0).toDouble(),
          currentStreak: stats['currentStreak'] ?? 0,
          longestStreak: stats['longestStreak'] ?? 0,
          rank: rank++,
        ));
      }

      return leaderboard;
    } catch (e) {
      throw Exception('Failed to get friends leaderboard: $e');
    }
  }

  @override
  Future<LeaderboardEntity?> getUserRank(String userId) async {
    try {
      final allUsersSnapshot = await firestore
          .collection('users')
          .where('stats.totalPoints', isGreaterThan: 0)
          .orderBy('stats.totalPoints', descending: true)
          .get();

      int rank = 1;
      for (final doc in allUsersSnapshot.docs) {
        if (doc.id == userId) {
          final data = doc.data();
          final stats = data['stats'] as Map<String, dynamic>? ?? {};

          return LeaderboardEntity(
            userId: data['uid'] ?? '',
            displayName: data['displayName'] ?? '',
            photoUrl: data['photoURL'],
            totalPoints: stats['totalPoints'] ?? 0,
            totalQuizzes: stats['totalQuizzes'] ?? 0,
            accuracyPercentage: (stats['accuracyPercentage'] ?? 0).toDouble(),
            currentStreak: stats['currentStreak'] ?? 0,
            longestStreak: stats['longestStreak'] ?? 0,
            rank: rank,
          );
        }
        rank++;
      }

      return null;
    } catch (e) {
      throw Exception('Failed to get user rank: $e');
    }
  }
}
