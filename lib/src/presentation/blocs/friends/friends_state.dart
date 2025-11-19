import 'package:equatable/equatable.dart';
import '../../../domain/entities/friend_entity.dart';
import '../../../domain/entities/friend_request_entity.dart';

abstract class FriendsState extends Equatable {
  const FriendsState();

  @override
  List<Object?> get props => [];
}

class FriendsInitial extends FriendsState {
  const FriendsInitial();
}

class FriendsLoading extends FriendsState {
  const FriendsLoading();
}

class FriendsLoaded extends FriendsState {
  final List<Friend> friends;
  final List<FriendRequest> friendRequests;
  final List<Friend> searchResults;
  final bool isSearching;

  const FriendsLoaded({
    required this.friends,
    required this.friendRequests,
    this.searchResults = const [],
    this.isSearching = false,
  });

  FriendsLoaded copyWith({
    List<Friend>? friends,
    List<FriendRequest>? friendRequests,
    List<Friend>? searchResults,
    bool? isSearching,
  }) {
    return FriendsLoaded(
      friends: friends ?? this.friends,
      friendRequests: friendRequests ?? this.friendRequests,
      searchResults: searchResults ?? this.searchResults,
      isSearching: isSearching ?? this.isSearching,
    );
  }

  @override
  List<Object?> get props => [friends, friendRequests, searchResults, isSearching];
}

class FriendsError extends FriendsState {
  final String message;
  final String? errorCode;

  const FriendsError({
    required this.message,
    this.errorCode,
  });

  @override
  List<Object?> get props => [message, errorCode];
}

class FriendRequestSent extends FriendsState {
  final String message;

  const FriendRequestSent({required this.message});

  @override
  List<Object?> get props => [message];
}

class FriendRequestAccepted extends FriendsState {
  final String message;

  const FriendRequestAccepted({required this.message});

  @override
  List<Object?> get props => [message];
}

class FriendRemoved extends FriendsState {
  final String message;

  const FriendRemoved({required this.message});

  @override
  List<Object?> get props => [message];
}

class UserBlocked extends FriendsState {
  final String message;

  const UserBlocked({required this.message});

  @override
  List<Object?> get props => [message];
}