import 'package:dartz/dartz.dart';
import '../../errors/failures.dart';
import '../../repositories/social_activity_repository.dart';
import '../entities/social_activity_entity.dart';

class GetFriendsActivityFeedUseCase {
  final SocialActivityRepository _repository;

  GetFriendsActivityFeedUseCase(this._repository);

  Stream<List<SocialActivity>> call(List<String> friendIds) {
    return _repository.getFriendsActivityFeed(friendIds);
  }
}
