import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:quiz_champ/src/core/error/failures.dart';
import 'package:quiz_champ/src/data/models/question_model.dart';

abstract class QuizRemoteDataSource {
  Future<List<QuestionModel>> fetchQuestions({
    int amount = 10,
    String? category,
    String? difficulty,
  });
}

class QuizRemoteDataSourceImpl implements QuizRemoteDataSource {
  final Dio client;
  static const int maxRetries = 3;
  static const Duration baseDelay = Duration(seconds: 1);

  QuizRemoteDataSourceImpl({required this.client}) {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    client.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Ensure we always request multiple choice questions
          options.queryParameters['type'] = 'multiple';
          handler.next(options);
        },
        onError: (error, handler) {
          // Log error for debugging
          print('OpenTDB API Error: ${error.message}');
          handler.next(error);
        },
      ),
    );
  }

  @override
  Future<List<QuestionModel>> fetchQuestions({
    int amount = 10,
    String? category,
    String? difficulty,
  }) async {
    return _fetchWithRetry(
      amount: amount,
      category: category,
      difficulty: difficulty,
    );
  }

  Future<List<QuestionModel>> _fetchWithRetry({
    required int amount,
    String? category,
    String? difficulty,
    int retryCount = 0,
  }) async {
    try {
      final response = await client.get(
        '/api.php',
        queryParameters: {
          'amount': amount,
          'type': 'multiple', // Always fetch multiple choice questions
          if (category != null) 'category': category,
          if (difficulty != null) 'difficulty': difficulty,
        },
      );

      return _processResponse(response);
    } on DioException catch (e) {
      if (retryCount < maxRetries && _shouldRetry(e)) {
        final delay = _calculateDelay(retryCount);
        await Future.delayed(delay);
        return _fetchWithRetry(
          amount: amount,
          category: category,
          difficulty: difficulty,
          retryCount: retryCount + 1,
        );
      }
      
      throw _mapDioException(e);
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(message: 'An unknown error occurred: $e');
    }
  }

  List<QuestionModel> _processResponse(Response response) {
    if (response.statusCode != 200) {
      throw ServerFailure(message: 'Failed to load questions: ${response.statusCode}');
    }

    final data = response.data;
    if (data == null || data is! Map<String, dynamic>) {
      throw ServerFailure(message: 'Invalid response format');
    }

    final responseCode = data['response_code'];
    
    switch (responseCode) {
      case 0: // Success
        final List<dynamic> results = data['results'] ?? [];
        if (results.isEmpty) {
          throw ServerFailure(message: 'No questions available for the specified criteria');
        }
        return results.map((json) => QuestionModel.fromJson(json)).toList();
      
      case 1: // No Results
        throw ServerFailure(message: 'No questions found for the specified criteria');
      
      case 2: // Invalid Parameter
        throw ServerFailure(message: 'Invalid parameters provided to OpenTDB API');
      
      case 3: // Token Not Found
        throw ServerFailure(message: 'Session token not found');
      
      case 4: // Token Empty
        throw ServerFailure(message: 'Session token has returned all possible questions');
      
      case 5: // Rate Limit
        throw ServerFailure(message: 'Too many requests. Please try again later');
      
      default:
        throw ServerFailure(message: 'OpenTDB API Error: Code $responseCode');
    }
  }

  bool _shouldRetry(DioException e) {
    // Retry on network errors, timeouts, and server errors (5xx)
    return e.type == DioExceptionType.connectionTimeout ||
           e.type == DioExceptionType.receiveTimeout ||
           e.type == DioExceptionType.sendTimeout ||
           e.type == DioExceptionType.connectionError ||
           (e.response?.statusCode != null && e.response!.statusCode! >= 500);
  }

  Duration _calculateDelay(int retryCount) {
    // Exponential backoff with jitter
    final exponentialDelay = baseDelay * pow(2, retryCount);
    final jitter = Duration(milliseconds: Random().nextInt(1000));
    return exponentialDelay + jitter;
  }

  Failure _mapDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return NetworkFailure();
      
      case DioExceptionType.connectionError:
        return NetworkFailure();
      
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 429) {
          return ServerFailure(message: 'Rate limit exceeded. Please try again later');
        }
        return ServerFailure(message: 'Server error: ${statusCode ?? 'Unknown'}');
      
      default:
        return ServerFailure(message: e.message ?? 'Network error occurred');
    }
  }
}
