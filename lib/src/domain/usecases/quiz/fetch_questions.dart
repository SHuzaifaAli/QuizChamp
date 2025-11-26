import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/error/failures.dart';
import '../../../domain/repositories/question_repository.dart';
import '../../../domain/entities/question_entity.dart';

class FetchQuestions {
  final QuestionRepository repository;

  FetchQuestions(this.repository);

  Future<Either<Failure, List<Question>>> call({
    int amount = 10,
    String? category,
    String? difficulty,
  }) async {
    try {
      final questionsResult = await repository.fetchQuestions(
        amount: amount,
        category: category,
        difficulty: difficulty,
      );
      return questionsResult;
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

class FetchQuestionsParams extends Equatable {
  final int amount;
  final String? category;
  final String? difficulty;

  const FetchQuestionsParams({
    this.amount = 10,
    this.category,
    this.difficulty,
  });

  @override
  List<Object?> get props => [amount, category, difficulty];
}
