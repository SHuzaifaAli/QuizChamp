import 'package:dartz/dartz.dart';
import '../entities/quiz_session_entity.dart';
import '../entities/user_answer_entity.dart';
import '../../core/error/failures.dart';

abstract class QuizRepository {
  Future<Either<Failure, QuizSession>> createQuizSession({
    required int questionCount,
    String? category,
    String? difficulty,
  });
  
  Future<Either<Failure, QuizSession>> updateQuizSession(QuizSession session);
  Future<Either<Failure, QuizSession>> addAnswerToSession({
    required String sessionId,
    required UserAnswer answer,
  });
  
  Future<Either<Failure, void>> completeQuizSession(String sessionId);
  Future<Either<Failure, QuizSession?>> getCurrentSession();
}