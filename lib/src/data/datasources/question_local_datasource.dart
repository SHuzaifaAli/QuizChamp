import 'package:hive_flutter/hive_flutter.dart';
import '../models/question_model.dart';
import '../../core/error/failures.dart';

abstract class QuestionLocalDataSource {
  Future<List<QuestionModel>> getCachedQuestions(int amount);
  Future<void> cacheQuestions(List<QuestionModel> questions);
  Future<int> getCachedQuestionCount();
  Future<void> clearCache();
}

class QuestionLocalDataSourceImpl implements QuestionLocalDataSource {
  static const String _boxName = 'questions_cache';
  static const int _maxCacheSize = 200; // Maximum number of questions to cache
  
  Box<Map>? _questionsBox;

  Future<Box<Map>> get questionsBox async {
    _questionsBox ??= await Hive.openBox<Map>(_boxName);
    return _questionsBox!;
  }

  @override
  Future<List<QuestionModel>> getCachedQuestions(int amount) async {
    try {
      final box = await questionsBox;
      final allQuestions = <QuestionModel>[];

      // Get all cached questions
      for (final key in box.keys) {
        final questionData = box.get(key);
        if (questionData != null) {
          try {
            final question = QuestionModel.fromJson(
              Map<String, dynamic>.from(questionData),
            );
            allQuestions.add(question);
          } catch (e) {
            // Skip invalid question data
            continue;
          }
        }
      }

      // Shuffle and return requested amount
      allQuestions.shuffle();
      return allQuestions.take(amount).toList();
    } catch (e) {
      throw CacheFailure();
    }
  }

  @override
  Future<void> cacheQuestions(List<QuestionModel> questions) async {
    try {
      final box = await questionsBox;
      
      // Add new questions to cache
      for (final question in questions) {
        await box.put(question.id, question.toJson());
      }

      // Manage cache size - remove oldest entries if we exceed max size
      await _manageCacheSize();
    } catch (e) {
      throw CacheFailure();
    }
  }

  @override
  Future<int> getCachedQuestionCount() async {
    try {
      final box = await questionsBox;
      return box.length;
    } catch (e) {
      throw CacheFailure();
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      final box = await questionsBox;
      await box.clear();
    } catch (e) {
      throw CacheFailure();
    }
  }

  Future<void> _manageCacheSize() async {
    final box = await questionsBox;
    
    if (box.length > _maxCacheSize) {
      // Remove oldest entries (first 20% of excess)
      final excessCount = box.length - _maxCacheSize;
      final toRemoveCount = (excessCount * 0.2).ceil().clamp(1, excessCount);
      
      final keysToRemove = box.keys.take(toRemoveCount).toList();
      for (final key in keysToRemove) {
        await box.delete(key);
      }
    }
  }

  /// Get questions by category from cache
  Future<List<QuestionModel>> getCachedQuestionsByCategory(
    String category,
    int amount,
  ) async {
    try {
      final box = await questionsBox;
      final categoryQuestions = <QuestionModel>[];

      for (final key in box.keys) {
        final questionData = box.get(key);
        if (questionData != null) {
          try {
            final question = QuestionModel.fromJson(
              Map<String, dynamic>.from(questionData),
            );
            if (question.category.toLowerCase() == category.toLowerCase()) {
              categoryQuestions.add(question);
            }
          } catch (e) {
            continue;
          }
        }
      }

      categoryQuestions.shuffle();
      return categoryQuestions.take(amount).toList();
    } catch (e) {
      throw CacheFailure();
    }
  }

  /// Get questions by difficulty from cache
  Future<List<QuestionModel>> getCachedQuestionsByDifficulty(
    String difficulty,
    int amount,
  ) async {
    try {
      final box = await questionsBox;
      final difficultyQuestions = <QuestionModel>[];

      for (final key in box.keys) {
        final questionData = box.get(key);
        if (questionData != null) {
          try {
            final question = QuestionModel.fromJson(
              Map<String, dynamic>.from(questionData),
            );
            if (question.difficulty.toLowerCase() == difficulty.toLowerCase()) {
              difficultyQuestions.add(question);
            }
          } catch (e) {
            continue;
          }
        }
      }

      difficultyQuestions.shuffle();
      return difficultyQuestions.take(amount).toList();
    } catch (e) {
      throw CacheFailure();
    }
  }

  /// Check if question already exists in cache
  Future<bool> questionExists(String questionId) async {
    try {
      final box = await questionsBox;
      return box.containsKey(questionId);
    } catch (e) {
      return false;
    }
  }
}