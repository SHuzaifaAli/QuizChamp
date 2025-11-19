import 'package:dartz/dartz.dart';
import '../../domain/entities/question_entity.dart';
import '../../domain/repositories/question_repository.dart';
import '../../core/error/failures.dart';
import '../datasources/question_remote_datasource.dart';
import '../datasources/question_local_datasource.dart';
import '../models/question_model.dart';

class QuestionRepositoryImpl implements QuestionRepository {
  final QuestionRemoteDataSource remoteDataSource;
  final QuestionLocalDataSource localDataSource;

  QuestionRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<Question>>> fetchQuestions({
    required int amount,
    String? category,
    String? difficulty,
  }) async {
    try {
      // Try to fetch from remote first
      final remoteQuestions = await remoteDataSource.fetchQuestions(
        amount: amount,
        category: category,
        difficulty: difficulty,
      );

      // Cache the fetched questions
      await localDataSource.cacheQuestions(remoteQuestions);

      // Return as domain entities
      return Right(remoteQuestions.cast<Question>());
    } on Failure catch (failure) {
      // If remote fails, try to get from cache
      return await _getCachedQuestionsAsFallback(amount, category, difficulty);
    } catch (e) {
      // If remote fails with unexpected error, try cache
      return await _getCachedQuestionsAsFallback(amount, category, difficulty);
    }
  }

  @override
  Future<Either<Failure, List<Question>>> getCachedQuestions(int amount) async {
    try {
      final cachedQuestions = await localDataSource.getCachedQuestions(amount);
      
      if (cachedQuestions.isEmpty) {
        return Left(CacheFailure());
      }

      // Reshuffle answers for each question to provide variety
      final reshuffledQuestions = cachedQuestions
          .map((question) => question.reshuffle())
          .cast<Question>()
          .toList();

      return Right(reshuffledQuestions);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> cacheQuestions(List<Question> questions) async {
    try {
      final questionModels = questions
          .map((question) => QuestionModel.fromEntity(question))
          .toList();
      
      await localDataSource.cacheQuestions(questionModels);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<int> getCachedQuestionCount() async {
    try {
      return await localDataSource.getCachedQuestionCount();
    } catch (e) {
      return 0;
    }
  }

  /// Private method to get cached questions as fallback
  Future<Either<Failure, List<Question>>> _getCachedQuestionsAsFallback(
    int amount,
    String? category,
    String? difficulty,
  ) async {
    try {
      List<QuestionModel> cachedQuestions;

      // Try to get questions matching the criteria
      if (category != null && category.isNotEmpty) {
        cachedQuestions = await (localDataSource as QuestionLocalDataSourceImpl)
            .getCachedQuestionsByCategory(category, amount);
      } else if (difficulty != null && difficulty.isNotEmpty) {
        cachedQuestions = await (localDataSource as QuestionLocalDataSourceImpl)
            .getCachedQuestionsByDifficulty(difficulty, amount);
      } else {
        cachedQuestions = await localDataSource.getCachedQuestions(amount);
      }

      if (cachedQuestions.isEmpty) {
        return Left(NetworkFailure());
      }

      // Reshuffle answers for variety
      final reshuffledQuestions = cachedQuestions
          .map((question) => question.reshuffle())
          .cast<Question>()
          .toList();

      return Right(reshuffledQuestions);
    } catch (e) {
      return Left(NetworkFailure());
    }
  }

  /// Get questions with cache-first strategy
  Future<Either<Failure, List<Question>>> getQuestionsWithCacheFirst({
    required int amount,
    String? category,
    String? difficulty,
  }) async {
    // First try cache
    final cacheResult = await _getCachedQuestionsAsFallback(amount, category, difficulty);
    
    if (cacheResult.isRight()) {
      final cachedQuestions = cacheResult.getOrElse(() => []);
      
      // If we have enough cached questions, return them
      if (cachedQuestions.length >= amount) {
        return Right(cachedQuestions.take(amount).toList());
      }
    }

    // If cache doesn't have enough questions, fetch from remote
    return await fetchQuestions(
      amount: amount,
      category: category,
      difficulty: difficulty,
    );
  }

  /// Preload questions for better performance
  Future<Either<Failure, void>> preloadQuestions({
    int amount = 50,
    List<String>? categories,
    List<String>? difficulties,
  }) async {
    try {
      // Check current cache size
      final currentCacheSize = await getCachedQuestionCount();
      
      if (currentCacheSize >= amount) {
        return const Right(null); // Already have enough questions
      }

      final questionsToFetch = amount - currentCacheSize;

      // Fetch general questions
      final generalResult = await fetchQuestions(amount: questionsToFetch);
      
      if (generalResult.isLeft()) {
        return Left(generalResult.fold((failure) => failure, (_) => NetworkFailure()));
      }

      // Optionally fetch category-specific questions
      if (categories != null) {
        for (final category in categories) {
          try {
            await fetchQuestions(
              amount: 10,
              category: category,
            );
          } catch (e) {
            // Continue with other categories if one fails
            continue;
          }
        }
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to preload questions: ${e.toString()}'));
    }
  }

  /// Clear all cached questions
  Future<Either<Failure, void>> clearCache() async {
    try {
      await localDataSource.clearCache();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure());
    }
  }
}