import 'package:equatable/equatable.dart';

abstract class FriendsEvent extends Equatable {
  const FriendsEvent();

  @override
  List<Object?> get props => [];
}

class LoadFriendsEvent extends FriendsEvent {
  final String userId;

  const LoadFriendsEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class SendFriendRequestEvent extends FriendsEvent {
  final String fromUserId;
  final String toUserId;
  final String message;

  const SendFriendRequestEvent({
    required this.fromUserId,
    required this.toUserId,
    required this.message,
  });

  @override
  List<Object?> get props => [fromUserId, toUserId, message];
}

class AcceptFriendRequestEvent extends FriendsEvent {
  final String requestId;

  const AcceptFriendRequestEvent({required this.requestId});

  @override
  List<Object?> get props => [requestId];
}

class DeclineFriendRequestEvent extends FriendsEvent {
  final String requestId;

  const DeclineFriendRequestEvent({required this.requestId});

  @override
  List<Object?> get props => [requestId];
}

class RemoveFriendEvent extends FriendsEvent {
  final String userId;
  final String friendId;

  const RemoveFriendEvent({
    required this.userId,
    required this.friendId,
  });

  @override
  List<Object?> get props => [userId, friendId];
}

class SearchUsersEvent extends FriendsEvent {
  final String query;
  final String currentUserId;

  const SearchUsersEvent({
    required this.query,
    required this.currentUserId,
  });

  @override
  List<Object?> get props => [query, currentUserId];
}

class LoadFriendRequestsEvent extends FriendsEvent {
  final String userId;

  const LoadFriendRequestsEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class BlockUserEvent extends FriendsEvent {
  final String userId;
  final String blockedUserId;

  const BlockUserEvent({
    required this.userId,
    required this.blockedUserId,
  });

  @override
  List<Object?> get props => [userId, blockedUserId];
}

class ClearSearchResultsEvent extends FriendsEvent {
  const ClearSearchResultsEvent();
}