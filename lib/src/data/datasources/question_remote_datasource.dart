import 'package:dio/dio.dart';
import '../models/question_model.dart';
import '../../core/error/failures.dart';

abstract class QuestionRemoteDataSource {
  Future<List<QuestionModel>> fetchQuestions({
    required int amount,
    String? category,
    String? difficulty,
  });
}

class QuestionRemoteDataSourceImpl implements QuestionRemoteDataSource {
  final Dio dio;
  static const String baseUrl = 'https://opentdb.com/api.php';

  QuestionRemoteDataSourceImpl({required this.dio}) {
    _configureDio();
  }

  void _configureDio() {
    dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
    );

    // Add retry interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          if (_shouldRetry(error)) {
            try {
              final response = await _retryRequest(error.requestOptions);
              handler.resolve(response);
            } catch (e) {
              handler.next(error);
            }
          } else {
            handler.next(error);
          }
        },
      ),
    );

    // Add logging interceptor in debug mode
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (object) {
        // Only log in debug mode
        assert(() {
          print(object);
          return true;
        }());
      },
    ));
  }

  @override
  Future<List<QuestionModel>> fetchQuestions({
    required int amount,
    String? category,
    String? difficulty,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'amount': amount,
        'type': 'multiple', // Only multiple choice questions
      };

      if (category != null && category.isNotEmpty) {
        queryParameters['category'] = category;
      }

      if (difficulty != null && difficulty.isNotEmpty) {
        queryParameters['difficulty'] = difficulty;
      }

      final response = await dio.get(
        '',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final responseCode = data['response_code'] as int;

        switch (responseCode) {
          case 0: // Success
            final results = data['results'] as List<dynamic>;
            return results
                .map((json) => QuestionModel.fromJson(json as Map<String, dynamic>))
                .toList();
          case 1: // No Results
            throw ServerFailure(message: 'No questions found for the specified criteria');
          case 2: // Invalid Parameter
            throw ServerFailure(message: 'Invalid parameters provided');
          case 3: // Token Not Found
            throw ServerFailure(message: 'Session token not found');
          case 4: // Token Empty
            throw ServerFailure(message: 'Session token has returned all possible questions');
          default:
            throw ServerFailure(message: 'Unknown API response code: $responseCode');
        }
      } else {
        throw ServerFailure(message: 'HTTP ${response.statusCode}: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerFailure(message: 'Unexpected error: ${e.toString()}');
    }
  }

  bool _shouldRetry(DioException error) {
    // Retry on network errors and server errors (5xx)
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.connectionError ||
        (error.response?.statusCode != null && error.response!.statusCode! >= 500);
  }

  Future<Response> _retryRequest(RequestOptions requestOptions) async {
    // Exponential backoff: wait 1 second, then 2 seconds, then 4 seconds
    for (int attempt = 1; attempt <= 3; attempt++) {
      await Future.delayed(Duration(seconds: attempt));
      
      try {
        return await dio.request(
          requestOptions.path,
          data: requestOptions.data,
          queryParameters: requestOptions.queryParameters,
          options: Options(
            method: requestOptions.method,
            headers: requestOptions.headers,
          ),
        );
      } on DioException catch (e) {
        if (attempt == 3 || !_shouldRetry(e)) {
          rethrow;
        }
      }
    }
    
    throw ServerFailure(message: 'Max retry attempts exceeded');
  }

  Failure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return NetworkFailure();
      case DioExceptionType.connectionError:
        return NetworkFailure();
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode != null && statusCode >= 500) {
          return ServerFailure(message: 'Server error: $statusCode');
        } else if (statusCode == 429) {
          return ServerFailure(message: 'Rate limit exceeded. Please try again later.');
        } else {
          return ServerFailure(message: 'HTTP $statusCode: ${error.response?.statusMessage}');
        }
      case DioExceptionType.cancel:
        return ServerFailure(message: 'Request was cancelled');
      case DioExceptionType.unknown:
        return NetworkFailure();
      default:
        return ServerFailure(message: 'Unknown network error: ${error.message}');
    }
  }
}