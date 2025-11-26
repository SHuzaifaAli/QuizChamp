import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';

abstract class HeartsService {
  Future<int> getCurrentHearts();
  Future<Either<Failure, void>> consumeHeart();
  Stream<int> get heartsStream;
  int getMaxHearts();
  Future<Duration> getTimeToNextHeart();
  Future<Either<Failure, void>> addHearts(int amount);
  Future<Either<Failure, void>> regenerateHeart();
  void startRegenerationTimer();
}