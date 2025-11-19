import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../entities/quiz_session_entity.dart';
import '../../repositories/quiz_repository.dart';
import '../../repositories/hearts_service.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';

class StartQuizUseCase implements UseCase<QuizSession, StartQuizParams> {
  final QuizRepository quizRepository;
  final HeartsService heartsService;

  StartQuizUseCase({
    required this.quizRepository,
    required this.heartsService,
  });

  @override
  Future<Either<Failure, QuizSession>> call(StartQuizParams params) async {
    // Check if user has enough hearts
    final currentHearts = await heartsService.getCurrentHearts();
    if (currentHearts <= 0) {
      return Left(InsufficientHeartsFailure(availableHearts: currentHearts));
    }

    // Consume a heart
    final consumeResult = await heartsService.consumeHeart();
    if (consumeResult.isLeft()) {
      return Left(consumeResult.fold((failure) => failure, (_) => ServerFailure(message: 'Unknown error')));
    }

    // Create quiz session
    return await quizRepository.createQuizSession(
      questionCount: params.questionCount,
      category: params.category,
      difficulty: params.difficulty,
    );
  }
}

class StartQuizParams extends Equatable {
  final int questionCount;
  final String? category;
  final String? difficulty;

  const StartQuizParams({
    required this.questionCount,
    this.category,
    this.difficulty,
  });

  @override
  List<Object?> get props => [questionCount, category, difficulty];
}