import 'package:dartz/dartz.dart';
import '../entities/friend_entity.dart';
import '../entities/friend_request_entity.dart';
import '../../core/error/failures.dart';

abstract class FriendsRepository {
  Stream<List<Friend>> getFriendsStream(String userId);
  Future<Either<Failure, void>> sendFriendRequest(String fromUserId, String toUserId, String message);
  Future<Either<Failure, void>> acceptFriendRequest(String requestId);
  Future<Either<Failure, void>> declineFriendRequest(String requestId);
  Future<Either<Failure, void>> removeFriend(String userId, String friendId);
  Future<Either<Failure, List<Friend>>> searchUsers(String query, String currentUserId);
  Stream<List<FriendRequest>> getFriendRequestsStream(String userId);
  Future<Either<Failure, Friend?>> getFriendById(String userId, String friendId);
  Future<Either<Failure, void>> blockUser(String userId, String blockedUserId);
  Future<Either<Failure, void>> unblockUser(String userId, String blockedUserId);
  Future<Either<Failure, List<String>>> getBlockedUsers(String userId);
}