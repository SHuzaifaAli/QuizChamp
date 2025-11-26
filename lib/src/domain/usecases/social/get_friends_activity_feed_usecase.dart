import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../domain/repositories/social_activity_repository.dart';
import '../../../domain/entities/social_activity_entity.dart';

class GetFriendsActivityFeedUseCase {
  final SocialActivityRepository _repository;

  GetFriendsActivityFeedUseCase(this._repository);

  Future<Either<Failure, Stream<List<SocialActivity>>>> call(String userId) async {
    try {
      final feedResult = await _repository.getFriendsActivityFeed(userId);
      return feedResult;
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
