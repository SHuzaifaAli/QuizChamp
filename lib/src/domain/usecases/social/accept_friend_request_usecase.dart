import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../repositories/friends_repository.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';

class AcceptFriendRequestUseCase implements UseCase<void, AcceptFriendRequestParams> {
  final FriendsRepository friendsRepository;

  AcceptFriendRequestUseCase({required this.friendsRepository});

  @override
  Future<Either<Failure, void>> call(AcceptFriendRequestParams params) async {
    if (params.requestId.trim().isEmpty) {
      return Left(FriendRequestFailure(message: 'Invalid request ID'));
    }

    return await friendsRepository.acceptFriendRequest(params.requestId);
  }
}

class AcceptFriendRequestParams extends Equatable {
  final String requestId;

  const AcceptFriendRequestParams({required this.requestId});

  @override
  List<Object?> get props => [requestId];
}