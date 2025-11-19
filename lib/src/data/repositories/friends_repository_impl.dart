import 'package:dartz/dartz.dart';
import '../../domain/entities/friend_entity.dart';
import '../../domain/entities/friend_request_entity.dart';
import '../../domain/repositories/friends_repository.dart';
import '../../core/error/failures.dart';
import '../datasources/friends_remote_datasource.dart';

class FriendsRepositoryImpl implements FriendsRepository {
  final FriendsRemoteDataSource remoteDataSource;

  FriendsRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<Friend>> getFriendsStream(String userId) {
    return remoteDataSource.getFriendsStream(userId).map(
      (friends) => friends.cast<Friend>(),
    );
  }

  @override
  Future<Either<Failure, void>> sendFriendRequest(String fromUserId, String toUserId, String message) async {
    try {
      await remoteDataSource.sendFriendRequest(fromUserId, toUserId, message);
      return const Right(null);
    } on FriendRequestFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(FriendRequestFailure(message: 'Failed to send friend request: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> acceptFriendRequest(String requestId) async {
    try {
      await remoteDataSource.acceptFriendRequest(requestId);
      return const Right(null);
    } on FriendRequestFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(FriendRequestFailure(message: 'Failed to accept friend request: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> declineFriendRequest(String requestId) async {
    try {
      await remoteDataSource.declineFriendRequest(requestId);
      return const Right(null);
    } on FriendRequestFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(FriendRequestFailure(message: 'Failed to decline friend request: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> removeFriend(String userId, String friendId) async {
    try {
      await remoteDataSource.removeFriend(userId, friendId);
      return const Right(null);
    } on FriendRequestFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(FriendRequestFailure(message: 'Failed to remove friend: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Friend>>> searchUsers(String query, String currentUserId) async {
    try {
      final users = await remoteDataSource.searchUsers(query, currentUserId);
      return Right(users.cast<Friend>());
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to search users: ${e.toString()}'));
    }
  }

  @override
  Stream<List<FriendRequest>> getFriendRequestsStream(String userId) {
    return remoteDataSource.getFriendRequestsStream(userId).map(
      (requests) => requests.cast<FriendRequest>(),
    );
  }

  @override
  Future<Either<Failure, Friend?>> getFriendById(String userId, String friendId) async {
    try {
      final friend = await remoteDataSource.getFriendById(userId, friendId);
      return Right(friend);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get friend: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> blockUser(String userId, String blockedUserId) async {
    try {
      await remoteDataSource.blockUser(userId, blockedUserId);
      return const Right(null);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to block user: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> unblockUser(String userId, String blockedUserId) async {
    try {
      await remoteDataSource.unblockUser(userId, blockedUserId);
      return const Right(null);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to unblock user: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getBlockedUsers(String userId) async {
    try {
      final blockedUsers = await remoteDataSource.getBlockedUsers(userId);
      return Right(blockedUsers);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get blocked users: ${e.toString()}'));
    }
  }
}