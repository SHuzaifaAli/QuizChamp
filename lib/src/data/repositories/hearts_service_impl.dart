import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/repositories/hearts_service.dart';
import '../../core/error/failures.dart';

class HeartsServiceImpl implements HeartsService {
  static const String _boxName = 'hearts_data';
  static const String _heartsKey = 'current_hearts';
  static const String _lastRegenKey = 'last_regeneration';
  static const int _maxHearts = 5;
  static const int _defaultHearts = 3;
  static const Duration _regenerationInterval = Duration(minutes: 30);

  Box<dynamic>? _heartsBox;
  final StreamController<int> _heartsController = StreamController<int>.broadcast();

  Future<Box<dynamic>> get heartsBox async {
    _heartsBox ??= await Hive.openBox<dynamic>(_boxName);
    return _heartsBox!;
  }

  @override
  Stream<int> get heartsStream => _heartsController.stream;

  @override
  Future<int> getCurrentHearts() async {
    try {
      final box = await heartsBox;
      
      // Check if hearts need regeneration
      await _regenerateHearts();
      
      final hearts = box.get(_heartsKey, defaultValue: _defaultHearts) as int;
      return hearts.clamp(0, _maxHearts);
    } catch (e) {
      return _defaultHearts;
    }
  }

  @override
  Future<Either<Failure, void>> consumeHeart() async {
    try {
      final box = await heartsBox;
      final currentHearts = await getCurrentHearts();
      
      if (currentHearts <= 0) {
        return Left(InsufficientHeartsFailure(availableHearts: currentHearts));
      }
      
      final newHearts = currentHearts - 1;
      await box.put(_heartsKey, newHearts);
      
      // Update last regeneration time if this is the first heart consumed
      if (currentHearts == _maxHearts) {
        await box.put(_lastRegenKey, DateTime.now().millisecondsSinceEpoch);
      }
      
      _heartsController.add(newHearts);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to consume heart: ${e.toString()}'));
    }
  }

  /// Add hearts (for purchases, rewards, etc.)
  Future<Either<Failure, void>> addHearts(int amount) async {
    try {
      final box = await heartsBox;
      final currentHearts = await getCurrentHearts();
      final newHearts = (currentHearts + amount).clamp(0, _maxHearts);
      
      await box.put(_heartsKey, newHearts);
      _heartsController.add(newHearts);
      
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to add hearts: ${e.toString()}'));
    }
  }

  /// Set hearts to maximum (for premium users, special events, etc.)
  Future<Either<Failure, void>> fillHearts() async {
    try {
      final box = await heartsBox;
      await box.put(_heartsKey, _maxHearts);
      await box.delete(_lastRegenKey); // Reset regeneration timer
      
      _heartsController.add(_maxHearts);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to fill hearts: ${e.toString()}'));
    }
  }

  /// Get time until next heart regeneration
  Future<Duration?> getTimeUntilNextRegeneration() async {
    try {
      final box = await heartsBox;
      final currentHearts = await getCurrentHearts();
      
      if (currentHearts >= _maxHearts) {
        return null; // No regeneration needed
      }
      
      final lastRegenTime = box.get(_lastRegenKey) as int?;
      if (lastRegenTime == null) {
        return null; // No regeneration in progress
      }
      
      final lastRegen = DateTime.fromMillisecondsSinceEpoch(lastRegenTime);
      final nextRegen = lastRegen.add(_regenerationInterval);
      final now = DateTime.now();
      
      if (now.isBefore(nextRegen)) {
        return nextRegen.difference(now);
      }
      
      return null; // Regeneration is due
    } catch (e) {
      return null;
    }
  }

  /// Get maximum hearts capacity
  int get maxHearts => _maxHearts;

  /// Get regeneration interval
  Duration get regenerationInterval => _regenerationInterval;

  /// Check if hearts are at maximum
  Future<bool> isAtMaxHearts() async {
    final currentHearts = await getCurrentHearts();
    return currentHearts >= _maxHearts;
  }

  /// Start automatic heart regeneration timer
  Timer? _regenerationTimer;
  
  void startRegenerationTimer() {
    _regenerationTimer?.cancel();
    _regenerationTimer = Timer.periodic(const Duration(minutes: 1), (_) async {
      await _regenerateHearts();
    });
  }

  void stopRegenerationTimer() {
    _regenerationTimer?.cancel();
    _regenerationTimer = null;
  }

  /// Internal method to handle heart regeneration
  Future<void> _regenerateHearts() async {
    try {
      final box = await heartsBox;
      final currentHearts = box.get(_heartsKey, defaultValue: _defaultHearts) as int;
      
      if (currentHearts >= _maxHearts) {
        return; // Already at max
      }
      
      final lastRegenTime = box.get(_lastRegenKey) as int?;
      if (lastRegenTime == null) {
        // No regeneration in progress, start it
        await box.put(_lastRegenKey, DateTime.now().millisecondsSinceEpoch);
        return;
      }
      
      final lastRegen = DateTime.fromMillisecondsSinceEpoch(lastRegenTime);
      final now = DateTime.now();
      final timeSinceLastRegen = now.difference(lastRegen);
      
      // Calculate how many hearts should be regenerated
      final heartsToRegen = (timeSinceLastRegen.inMinutes / _regenerationInterval.inMinutes).floor();
      
      if (heartsToRegen > 0) {
        final newHearts = (currentHearts + heartsToRegen).clamp(0, _maxHearts);
        await box.put(_heartsKey, newHearts);
        
        if (newHearts >= _maxHearts) {
          // Remove regeneration timer when at max
          await box.delete(_lastRegenKey);
        } else {
          // Update last regeneration time
          final newLastRegen = lastRegen.add(Duration(minutes: heartsToRegen * _regenerationInterval.inMinutes));
          await box.put(_lastRegenKey, newLastRegen.millisecondsSinceEpoch);
        }
        
        _heartsController.add(newHearts);
      }
    } catch (e) {
      // Handle regeneration errors silently
    }
  }

  /// Reset hearts data (for testing or user reset)
  Future<Either<Failure, void>> resetHearts() async {
    try {
      final box = await heartsBox;
      await box.clear();
      await box.put(_heartsKey, _defaultHearts);
      
      _heartsController.add(_defaultHearts);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to reset hearts: ${e.toString()}'));
    }
  }

  /// Get hearts statistics
  Future<Map<String, dynamic>> getHeartsStats() async {
    try {
      final currentHearts = await getCurrentHearts();
      final timeUntilNext = await getTimeUntilNextRegeneration();
      final isAtMax = await isAtMaxHearts();
      
      return {
        'current_hearts': currentHearts,
        'max_hearts': _maxHearts,
        'is_at_max': isAtMax,
        'time_until_next_regen': timeUntilNext?.inMinutes,
        'regeneration_interval_minutes': _regenerationInterval.inMinutes,
      };
    } catch (e) {
      return {
        'current_hearts': _defaultHearts,
        'max_hearts': _maxHearts,
        'is_at_max': false,
        'time_until_next_regen': null,
        'regeneration_interval_minutes': _regenerationInterval.inMinutes,
      };
    }
  }

  /// Dispose resources
  void dispose() {
    stopRegenerationTimer();
    _heartsController.close();
  }
}