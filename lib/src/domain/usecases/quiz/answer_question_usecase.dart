import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../entities/quiz_session_entity.dart';
import '../../entities/user_answer_entity.dart';
import '../../repositories/quiz_repository.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';

class AnswerQuestionUseCase implements UseCase<QuizSession, AnswerQuestionParams> {
  final QuizRepository quizRepository;

  AnswerQuestionUseCase({required this.quizRepository});

  @override
  Future<Either<Failure, QuizSession>> call(AnswerQuestionParams params) async {
    // Create user answer
    final userAnswer = UserAnswer(
      questionId: params.questionId,
      selectedAnswerIndex: params.selectedAnswerIndex,
      isCorrect: params.isCorrect,
      timeToAnswer: params.timeToAnswer,
      answeredAt: DateTime.now(),
    );

    // Add answer to session
    return await quizRepository.addAnswerToSession(
      sessionId: params.sessionId,
      answer: userAnswer,
    );
  }
}

class AnswerQuestionParams extends Equatable {
  final String sessionId;
  final String questionId;
  final int selectedAnswerIndex;
  final bool isCorrect;
  final Duration timeToAnswer;

  const AnswerQuestionParams({
    required this.sessionId,
    required this.questionId,
    required this.selectedAnswerIndex,
    required this.isCorrect,
    required this.timeToAnswer,
  });

  @override
  List<Object?> get props => [
        sessionId,
        questionId,
        selectedAnswerIndex,
        isCorrect,
        timeToAnswer,
      ];
}