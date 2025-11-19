import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:quiz_champ/src/core/error/failures.dart';
import 'package:quiz_champ/src/core/usecases/usecase.dart';
import 'package:quiz_champ/src/domain/entities/question_entity.dart';
import 'package:quiz_champ/src/domain/repositories/quiz_repository.dart';

class FetchQuestions implements UseCase<List<QuestionEntity>, FetchQuestionsParams> {
  final QuizRepository repository;

  FetchQuestions(this.repository);

  @override
  Future<Either<Failure, List<QuestionEntity>>> call(FetchQuestionsParams params) async {
    return await repository.fetchQuestions(
      amount: params.amount,
      category: params.category,
      difficulty: params.difficulty,
      type: params.type,
    );
  }
}

class FetchQuestionsParams extends Equatable {
  final int amount;
  final String? category;
  final String? difficulty;
  final String? type;

  const FetchQuestionsParams({
    this.amount = 10,
    this.category,
    this.difficulty,
    this.type,
  });

  @override
  List<Object?> get props => [amount, category, difficulty, type];
}
