import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/friend_model.dart';
import '../models/friend_request_model.dart';
import '../../core/error/failures.dart';

abstract class FriendsRemoteDataSource {
  Stream<List<FriendModel>> getFriendsStream(String userId);
  Future<void> sendFriendRequest(String fromUserId, String toUserId, String message);
  Future<void> acceptFriendRequest(String requestId);
  Future<void> declineFriendRequest(String requestId);
  Future<void> removeFriend(String userId, String friendId);
  Future<List<FriendModel>> searchUsers(String query, String currentUserId);
  Stream<List<FriendRequestModel>> getFriendRequestsStream(String userId);
  Future<FriendModel?> getFriendById(String userId, String friendId);
  Future<void> blockUser(String userId, String blockedUserId);
  Future<void> unblockUser(String userId, String blockedUserId);
  Future<List<String>> getBlockedUsers(String userId);
  Future<void> updateUserOnlineStatus(String userId, bool isOnline);
}

class FriendsRemoteDataSourceImpl implements FriendsRemoteDataSource {
  final FirebaseFirestore firestore;

  FriendsRemoteDataSourceImpl({required this.firestore});

  @override
  Stream<List<FriendModel>> getFriendsStream(String userId) {
    return firestore
        .collection('users')
        .doc(userId)
        .collection('friends')
        .where('status', isEqualTo: 'accepted')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FriendModel.fromFirestore(doc))
            .toList());
  }

  @override
  Future<void> sendFriendRequest(String fromUserId, String toUserId, String message) async {
    try {
      // Check if users are already friends
      final existingFriend = await firestore
          .collection('users')
          .doc(fromUserId)
          .collection('friends')
          .doc(toUserId)
          .get();

      if (existingFriend.exists) {
        throw FriendRequestFailure(message: 'Users are already friends');
      }

      // Check if there's already a pending request
      final existingRequest = await firestore
          .collection('friendRequests')
          .where('fromUserId', isEqualTo: fromUserId)
          .where('toUserId', isEqualTo: toUserId)
          .where('status', isEqualTo: 'pending')
          .get();

      if (existingRequest.docs.isNotEmpty) {
        throw FriendRequestFailure(message: 'Friend request already sent');
      }

      // Get user details
      final fromUserDoc = await firestore.collection('users').doc(fromUserId).get();
      final toUserDoc = await firestore.collection('users').doc(toUserId).get();

      if (!fromUserDoc.exists || !toUserDoc.exists) {
        throw FriendRequestFailure(message: 'User not found');
      }

      final fromUserData = fromUserDoc.data()!;
      final toUserData = toUserDoc.data()!;

      // Create friend request
      final request = FriendRequestModel(
        id: '',
        fromUserId: fromUserId,
        toUserId: toUserId,
        fromUserName: fromUserData['displayName'] ?? '',
        toUserName: toUserData['displayName'] ?? '',
        fromUserPhotoUrl: fromUserData['photoUrl'],
        toUserPhotoUrl: toUserData['photoUrl'],
        message: message,
        sentAt: DateTime.now(),
        status: FriendRequestStatus.pending,
      );

      await firestore.collection('friendRequests').add(request.toFirestore());
    } catch (e) {
      if (e is FriendRequestFailure) rethrow;
      throw FriendRequestFailure(message: 'Failed to send friend request: ${e.toString()}');
    }
  }

  @override
  Future<void> acceptFriendRequest(String requestId) async {
    try {
      final requestDoc = await firestore.collection('friendRequests').doc(requestId).get();
      
      if (!requestDoc.exists) {
        throw FriendRequestFailure(message: 'Friend request not found');
      }

      final request = FriendRequestModel.fromFirestore(requestDoc);
      
      if (request.status != FriendRequestStatus.pending) {
        throw FriendRequestFailure(message: 'Friend request is no longer pending');
      }

      // Create bidirectional friendship
      final batch = firestore.batch();
      final now = DateTime.now();

      // Add friend to requester's friend list
      final requesterFriendRef = firestore
          .collection('users')
          .doc(request.fromUserId)
          .collection('friends')
          .doc(request.toUserId);

      final requesterFriend = FriendModel(
        id: request.toUserId,
        userId: request.toUserId,
        displayName: request.toUserName,
        photoUrl: request.toUserPhotoUrl,
        friendsSince: now,
        isOnline: false,
        lastSeen: now,
        status: FriendshipStatus.accepted,
        stats: const SocialStatsModel(
          totalQuizzes: 0,
          correctAnswers: 0,
          accuracyPercentage: 0.0,
          currentStreak: 0,
          longestStreak: 0,
          totalPoints: 0,
          lastQuizDate: null,
        ),
      );

      batch.set(requesterFriendRef, requesterFriend.toFirestore());

      // Add friend to accepter's friend list
      final accepterFriendRef = firestore
          .collection('users')
          .doc(request.toUserId)
          .collection('friends')
          .doc(request.fromUserId);

      final accepterFriend = FriendModel(
        id: request.fromUserId,
        userId: request.fromUserId,
        displayName: request.fromUserName,
        photoUrl: request.fromUserPhotoUrl,
        friendsSince: now,
        isOnline: false,
        lastSeen: now,
        status: FriendshipStatus.accepted,
        stats: const SocialStatsModel(
          totalQuizzes: 0,
          correctAnswers: 0,
          accuracyPercentage: 0.0,
          currentStreak: 0,
          longestStreak: 0,
          totalPoints: 0,
          lastQuizDate: null,
        ),
      );

      batch.set(accepterFriendRef, accepterFriend.toFirestore());

      // Update friend request status
      batch.update(firestore.collection('friendRequests').doc(requestId), {
        'status': 'accepted',
        'respondedAt': Timestamp.fromDate(now),
      });

      await batch.commit();
    } catch (e) {
      if (e is FriendRequestFailure) rethrow;
      throw FriendRequestFailure(message: 'Failed to accept friend request: ${e.toString()}');
    }
  }

  @override
  Future<void> declineFriendRequest(String requestId) async {
    try {
      await firestore.collection('friendRequests').doc(requestId).update({
        'status': 'declined',
        'respondedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw FriendRequestFailure(message: 'Failed to decline friend request: ${e.toString()}');
    }
  }

  @override
  Future<void> removeFriend(String userId, String friendId) async {
    try {
      final batch = firestore.batch();

      // Remove from both users' friend lists
      batch.delete(firestore
          .collection('users')
          .doc(userId)
          .collection('friends')
          .doc(friendId));

      batch.delete(firestore
          .collection('users')
          .doc(friendId)
          .collection('friends')
          .doc(userId));

      await batch.commit();
    } catch (e) {
      throw FriendRequestFailure(message: 'Failed to remove friend: ${e.toString()}');
    }
  }

  @override
  Future<List<FriendModel>> searchUsers(String query, String currentUserId) async {
    try {
      if (query.trim().isEmpty) return [];

      // Get blocked users to filter them out
      final blockedUsers = await getBlockedUsers(currentUserId);

      // Search by display name
      final querySnapshot = await firestore
          .collection('users')
          .where('displayName', isGreaterThanOrEqualTo: query)
          .where('displayName', isLessThan: query + '\uf8ff')
          .limit(15)
          .get();

      final results = <FriendModel>[];

      for (final doc in querySnapshot.docs) {
        if (doc.id == currentUserId) continue; // Skip current user
        if (blockedUsers.contains(doc.id)) continue; // Skip blocked users

        final userData = doc.data();
        final friend = FriendModel(
          id: doc.id,
          userId: doc.id,
          displayName: userData['displayName'] ?? '',
          photoUrl: userData['photoUrl'],
          email: userData['email'],
          friendsSince: DateTime.now(),
          isOnline: userData['isOnline'] ?? false,
          lastSeen: userData['lastSeen'] != null 
              ? (userData['lastSeen'] as Timestamp).toDate()
              : DateTime.now(),
          status: FriendshipStatus.pending,
          stats: SocialStatsModel.fromMap(userData['stats'] ?? {}),
        );

        results.add(friend);
      }

      return results;
    } catch (e) {
      throw ServerFailure(message: 'Failed to search users: ${e.toString()}');
    }
  }

  @override
  Stream<List<FriendRequestModel>> getFriendRequestsStream(String userId) {
    return firestore
        .collection('friendRequests')
        .where('toUserId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .orderBy('sentAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FriendRequestModel.fromFirestore(doc))
            .toList());
  }

  @override
  Future<FriendModel?> getFriendById(String userId, String friendId) async {
    try {
      final doc = await firestore
          .collection('users')
          .doc(userId)
          .collection('friends')
          .doc(friendId)
          .get();

      if (!doc.exists) return null;

      return FriendModel.fromFirestore(doc);
    } catch (e) {
      throw ServerFailure(message: 'Failed to get friend: ${e.toString()}');
    }
  }

  @override
  Future<void> blockUser(String userId, String blockedUserId) async {
    try {
      final batch = firestore.batch();

      // Add to blocked users list
      batch.set(
        firestore
            .collection('users')
            .doc(userId)
            .collection('blocked')
            .doc(blockedUserId),
        {
          'blockedAt': Timestamp.fromDate(DateTime.now()),
          'userId': blockedUserId,
        },
      );

      // Remove from friends if they are friends
      batch.delete(firestore
          .collection('users')
          .doc(userId)
          .collection('friends')
          .doc(blockedUserId));

      batch.delete(firestore
          .collection('users')
          .doc(blockedUserId)
          .collection('friends')
          .doc(userId));

      await batch.commit();
    } catch (e) {
      throw ServerFailure(message: 'Failed to block user: ${e.toString()}');
    }
  }

  @override
  Future<void> unblockUser(String userId, String blockedUserId) async {
    try {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('blocked')
          .doc(blockedUserId)
          .delete();
    } catch (e) {
      throw ServerFailure(message: 'Failed to unblock user: ${e.toString()}');
    }
  }

  @override
  Future<List<String>> getBlockedUsers(String userId) async {
    try {
      final snapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('blocked')
          .get();

      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      throw ServerFailure(message: 'Failed to get blocked users: ${e.toString()}');
    }
  }

  @override
  Future<void> updateUserOnlineStatus(String userId, bool isOnline) async {
    try {
      await firestore.collection('users').doc(userId).update({
        'isOnline': isOnline,
        'lastSeen': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw ServerFailure(message: 'Failed to update online status: ${e.toString()}');
    }
  }
}