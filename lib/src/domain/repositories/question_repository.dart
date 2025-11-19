import 'package:dartz/dartz.dart';
import '../entities/question_entity.dart';
import '../../core/error/failures.dart';

abstract class QuestionRepository {
  Future<Either<Failure, List<Question>>> fetchQuestions({
    required int amount,
    String? category,
    String? difficulty,
  });
  
  Future<Either<Failure, List<Question>>> getCachedQuestions(int amount);
  Future<Either<Failure, void>> cacheQuestions(List<Question> questions);
  Future<int> getCachedQuestionCount();
}