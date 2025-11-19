import 'package:hive_flutter/hive_flutter.dart';
import 'package:quiz_champ/src/core/error/failures.dart';
import 'package:quiz_champ/src/data/models/question_model.dart';

abstract class QuizLocalDataSource {
  Future<List<QuestionModel>> getCachedQuestions(int amount);
  Future<void> cacheQuestions(List<QuestionModel> questions);
  Future<int> getCachedQuestionCount();
  Future<void> clearCache();
}

class QuizLocalDataSourceImpl implements QuizLocalDataSource {
  static const String questionsBoxName = 'questions';
  static const int maxCacheSize = 100; // Maximum number of questions to cache

  Box<Map<dynamic, dynamic>>? _questionsBox;

  Future<Box<Map<dynamic, dynamic>>> get questionsBox async {
    _questionsBox ??= await Hive.openBox<Map<dynamic, dynamic>>(questionsBoxName);
    return _questionsBox!;
  }

  @override
  Future<List<QuestionModel>> getCachedQuestions(int amount) async {
    try {
      final box = await questionsBox;
      final cachedQuestions = <QuestionModel>[];
      
      // Get available question keys
      final keys = box.keys.toList();
      if (keys.isEmpty) {
        return [];
      }

      // Shuffle keys to get random questions
      keys.shuffle();
      
      // Take up to the requested amount
      final keysToUse = keys.take(amount).toList();
      
      for (final key in keysToUse) {
        final questionData = box.get(key);
        if (questionData != null) {
          try {
            final questionModel = QuestionModel.fromJson(
              Map<String, dynamic>.from(questionData)
            );
            cachedQuestions.add(questionModel);
          } catch (e) {
            // Skip invalid cached questions
            print('Error parsing cached question: $e');
            await box.delete(key); // Remove corrupted data
          }
        }
      }

      return cachedQuestions;
    } catch (e) {
      throw CacheFailure();
    }
  }

  @override
  Future<void> cacheQuestions(List<QuestionModel> questions) async {
    try {
      final box = await questionsBox;
      
      // Check if we need to make room for new questions
      await _manageCacheSize(questions.length);
      
      // Cache new questions
      for (final question in questions) {
        final key = question.id;
        final questionData = question.toJson();
        await box.put(key, questionData);
      }
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
      return 0;
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

  Future<void> _manageCacheSize(int newQuestionsCount) async {
    final box = await questionsBox;
    final currentCount = box.length;
    final totalAfterAdd = currentCount + newQuestionsCount;
    
    if (totalAfterAdd > maxCacheSize) {
      final questionsToRemove = totalAfterAdd - maxCacheSize;
      final keys = box.keys.toList();
      
      // Remove oldest questions (assuming keys are chronological)
      for (int i = 0; i < questionsToRemove && i < keys.length; i++) {
        await box.delete(keys[i]);
      }
    }
  }

  Future<void> dispose() async {
    await _questionsBox?.close();
    _questionsBox = null;
  }
}