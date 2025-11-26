import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../domain/repositories/social_activity_repository.dart';
import '../../../domain/entities/social_activity_entity.dart';

class AddReactionToActivityUseCase {
  final SocialActivityRepository _repository;

  AddReactionToActivityUseCase(this._repository);

  Future<Either<Failure, void>> call(String activityId, String userId, ReactionType reactionType) async {
    try {
      await _repository.reactToActivity(activityId, userId, reactionType);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

class AddReactionParams {
  final String activityId;
  final String userId;
  final ReactionType reactionType;

  AddReactionParams({
    required this.activityId,
    required this.userId,
    required this.reactionType,
  });
}
