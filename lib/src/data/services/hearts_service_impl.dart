import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:quiz_champ/src/core/error/failures.dart';
import 'package:quiz_champ/src/domain/repositories/hearts_service.dart';

class HeartsServiceImpl implements HeartsService {
  static const String heartsBoxName = 'hearts';
  static const String heartsKey = 'current_hearts';
  static const int maxHearts = 5;
  static const int initialHearts = 3;

  Box<int>? _heartsBox;
  final StreamController<int> _heartsController = StreamController<int>.broadcast();

  Future<Box<int>> get heartsBox async {
    _heartsBox ??= await Hive.openBox<int>(heartsBoxName);
    return _heartsBox!;
  }

  @override
  Stream<int> get heartsStream => _heartsController.stream;

  @override
  Future<int> getCurrentHearts() async {
    try {
      final box = await heartsBox;
      final hearts = box.get(heartsKey, defaultValue: initialHearts) ?? initialHearts;
      
      // Ensure hearts don't exceed maximum
      final validHearts = hearts.clamp(0, maxHearts);
      
      if (validHearts != hearts) {
        await _updateHearts(validHearts);
      }
      
      return validHearts;
    } catch (e) {
      // Return initial hearts if there's an error reading from storage
      return initialHearts;
    }
  }

  @override
  Future<Either<Failure, void>> consumeHeart() async {
    try {
      final currentHearts = await getCurrentHearts();
      
      if (currentHearts <= 0) {
        return Left(InsufficientHeartsFailure(availableHearts: currentHearts));
      }
      
      final newHearts = currentHearts - 1;
      await _updateHearts(newHearts);
      
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  Future<void> _updateHearts(int hearts) async {
    try {
      final box = await heartsBox;
      await box.put(heartsKey, hearts);
      
      // Notify listeners of the change
      _heartsController.add(hearts);
    } catch (e) {
      throw CacheFailure();
    }
  }

  // Additional methods for hearts management (not in interface but useful)
  Future<Either<Failure, void>> addHearts(int amount) async {
    try {
      final currentHearts = await getCurrentHearts();
      final newHearts = (currentHearts + amount).clamp(0, maxHearts);
      
      await _updateHearts(newHearts);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  Future<Either<Failure, void>> resetHearts() async {
    try {
      await _updateHearts(maxHearts);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  Future<bool> canStartQuiz() async {
    final hearts = await getCurrentHearts();
    return hearts > 0;
  }

  Future<Duration> getTimeUntilNextHeart() async {
    // This would typically be implemented with a timer system
    // For now, return a placeholder
    return const Duration(minutes: 30);
  }

  Future<void> dispose() async {
    await _heartsController.close();
    await _heartsBox?.close();
    _heartsBox = null;
  }
}