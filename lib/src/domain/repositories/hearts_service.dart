import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';

abstract class HeartsService {
  Future<int> getCurrentHearts();
  Future<Either<Failure, void>> consumeHeart();
  Stream<int> get heartsStream;
}