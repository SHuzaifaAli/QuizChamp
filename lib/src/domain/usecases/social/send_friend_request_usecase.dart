import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../repositories/friends_repository.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';

class SendFriendRequestUseCase implements UseCase<void, SendFriendRequestParams> {
  final FriendsRepository friendsRepository;

  SendFriendRequestUseCase({required this.friendsRepository});

  @override
  Future<Either<Failure, void>> call(SendFriendRequestParams params) async {
    if (params.fromUserId == params.toUserId) {
      return Left(FriendRequestFailure(message: 'Cannot send friend request to yourself'));
    }

    if (params.message.trim().isEmpty) {
      return Left(FriendRequestFailure(message: 'Friend request message cannot be empty'));
    }

    return await friendsRepository.sendFriendRequest(
      params.fromUserId,
      params.toUserId,
      params.message,
    );
  }
}

class SendFriendRequestParams extends Equatable {
  final String fromUserId;
  final String toUserId;
  final String message;

  const SendFriendRequestParams({
    required this.fromUserId,
    required this.toUserId,
    required this.message,
  });

  @override
  List<Object?> get props => [fromUserId, toUserId, message];
}