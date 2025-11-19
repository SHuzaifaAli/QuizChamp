import 'package:dartz/dartz.dart';
import '../../errors/failures.dart';
import '../../repositories/social_activity_repository.dart';
import '../entities/social_activity_entity.dart';

class AddReactionToActivityUseCase {
  final SocialActivityRepository _repository;

  AddReactionToActivityUseCase(this._repository);

  Future<Either<Failure, void>> call(AddReactionParams params) async {
    try {
      await _repository.addReactionToActivity(
        params.activityId,
        params.userId,
        params.reactionType,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
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
