import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/friend_entity.dart';
import '../../../domain/entities/friend_request_entity.dart';
import '../../../domain/repositories/friends_repository.dart';
import '../../../domain/usecases/social/send_friend_request_usecase.dart';
import '../../../domain/usecases/social/accept_friend_request_usecase.dart';
import '../../../core/error/failures.dart';
import 'friends_event.dart';
import 'friends_state.dart';

class FriendsBloc extends Bloc<FriendsEvent, FriendsState> {
  final FriendsRepository friendsRepository;
  final SendFriendRequestUseCase sendFriendRequestUseCase;
  final AcceptFriendRequestUseCase acceptFriendRequestUseCase;

  StreamSubscription<List<Friend>>? _friendsSubscription;
  StreamSubscription<List<FriendRequest>>? _friendRequestsSubscription;

  List<Friend> _currentFriends = [];
  List<FriendRequest> _currentFriendRequests = [];

  FriendsBloc({
    required this.friendsRepository,
    required this.sendFriendRequestUseCase,
    required this.acceptFriendRequestUseCase,
  }) : super(const FriendsInitial()) {
    on<LoadFriendsEvent>(_onLoadFriends);
    on<SendFriendRequestEvent>(_onSendFriendRequest);
    on<AcceptFriendRequestEvent>(_onAcceptFriendRequest);
    on<DeclineFriendRequestEvent>(_onDeclineFriendRequest);
    on<RemoveFriendEvent>(_onRemoveFriend);
    on<SearchUsersEvent>(_onSearchUsers);
    on<LoadFriendRequestsEvent>(_onLoadFriendRequests);
    on<BlockUserEvent>(_onBlockUser);
    on<ClearSearchResultsEvent>(_onClearSearchResults);
  }

  Future<void> _onLoadFriends(LoadFriendsEvent event, Emitter<FriendsState> emit) async {
    emit(const FriendsLoading());

    try {
      _friendsSubscription?.cancel();
      _friendsSubscription = friendsRepository.getFriendsStream(event.userId).listen(
        (friends) {
          _currentFriends = friends;
          emit(FriendsLoaded(
            friends: _currentFriends,
            friendRequests: _currentFriendRequests,
          ));
        },
        onError: (error) {
          emit(FriendsError(message: 'Failed to load friends: ${error.toString()}'));
        },
      );
    } catch (e) {
      emit(FriendsError(message: 'Failed to load friends: ${e.toString()}'));
    }
  }

  Future<void> _onLoadFriendRequests(LoadFriendRequestsEvent event, Emitter<FriendsState> emit) async {
    try {
      _friendRequestsSubscription?.cancel();
      _friendRequestsSubscription = friendsRepository.getFriendRequestsStream(event.userId).listen(
        (requests) {
          _currentFriendRequests = requests;
          emit(FriendsLoaded(
            friends: _currentFriends,
            friendRequests: _currentFriendRequests,
          ));
        },
        onError: (error) {
          emit(FriendsError(message: 'Failed to load friend requests: ${error.toString()}'));
        },
      );
    } catch (e) {
      emit(FriendsError(message: 'Failed to load friend requests: ${e.toString()}'));
    }
  }

  Future<void> _onSendFriendRequest(SendFriendRequestEvent event, Emitter<FriendsState> emit) async {
    final result = await sendFriendRequestUseCase(SendFriendRequestParams(
      fromUserId: event.fromUserId,
      toUserId: event.toUserId,
      message: event.message,
    ));

    result.fold(
      (failure) => emit(FriendsError(message: _mapFailureToMessage(failure))),
      (_) => emit(const FriendRequestSent(message: 'Friend request sent successfully!')),
    );
  }

  Future<void> _onAcceptFriendRequest(AcceptFriendRequestEvent event, Emitter<FriendsState> emit) async {
    final result = await acceptFriendRequestUseCase(AcceptFriendRequestParams(
      requestId: event.requestId,
    ));

    result.fold(
      (failure) => emit(FriendsError(message: _mapFailureToMessage(failure))),
      (_) => emit(const FriendRequestAccepted(message: 'Friend request accepted!')),
    );
  }

  Future<void> _onDeclineFriendRequest(DeclineFriendRequestEvent event, Emitter<FriendsState> emit) async {
    final result = await friendsRepository.declineFriendRequest(event.requestId);

    result.fold(
      (failure) => emit(FriendsError(message: _mapFailureToMessage(failure))),
      (_) => emit(FriendsLoaded(
        friends: _currentFriends,
        friendRequests: _currentFriendRequests,
      )),
    );
  }

  Future<void> _onRemoveFriend(RemoveFriendEvent event, Emitter<FriendsState> emit) async {
    final result = await friendsRepository.removeFriend(event.userId, event.friendId);

    result.fold(
      (failure) => emit(FriendsError(message: _mapFailureToMessage(failure))),
      (_) => emit(const FriendRemoved(message: 'Friend removed successfully')),
    );
  }

  Future<void> _onSearchUsers(SearchUsersEvent event, Emitter<FriendsState> emit) async {
    if (event.query.trim().isEmpty) {
      emit(FriendsLoaded(
        friends: _currentFriends,
        friendRequests: _currentFriendRequests,
        searchResults: [],
        isSearching: false,
      ));
      return;
    }

    emit(FriendsLoaded(
      friends: _currentFriends,
      friendRequests: _currentFriendRequests,
      searchResults: [],
      isSearching: true,
    ));

    final result = await friendsRepository.searchUsers(event.query, event.currentUserId);

    result.fold(
      (failure) => emit(FriendsError(message: _mapFailureToMessage(failure))),
      (users) => emit(FriendsLoaded(
        friends: _currentFriends,
        friendRequests: _currentFriendRequests,
        searchResults: users,
        isSearching: false,
      )),
    );
  }

  Future<void> _onBlockUser(BlockUserEvent event, Emitter<FriendsState> emit) async {
    final result = await friendsRepository.blockUser(event.userId, event.blockedUserId);

    result.fold(
      (failure) => emit(FriendsError(message: _mapFailureToMessage(failure))),
      (_) => emit(const UserBlocked(message: 'User blocked successfully')),
    );
  }

  Future<void> _onClearSearchResults(ClearSearchResultsEvent event, Emitter<FriendsState> emit) async {
    emit(FriendsLoaded(
      friends: _currentFriends,
      friendRequests: _currentFriendRequests,
      searchResults: [],
      isSearching: false,
    ));
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is FriendRequestFailure) {
      return failure.message;
    } else if (failure is ServerFailure) {
      return failure.message;
    } else if (failure is NetworkFailure) {
      return 'Network error. Please check your connection.';
    } else {
      return 'An unexpected error occurred.';
    }
  }

  @override
  Future<void> close() {
    _friendsSubscription?.cancel();
    _friendRequestsSubscription?.cancel();
    return super.close();
  }
}