import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/repositories/hearts_service.dart';
import '../../core/error/failures.dart';

//repository/hearts_service_impl.dart
class HeartsServiceImpl implements HeartsService {
  static const String _boxName = 'hearts_data';
  static const String _heartsKey = 'current_hearts';
  static const String _lastRegenKey = 'last_regeneration';
  static const int _maxHearts = 5;
  static const int _defaultHearts = 3;
  static const Duration _regenerationInterval = Duration(minutes: 30);

  Box<dynamic>? _heartsBox;
  final StreamController<int> _heartsController =
      StreamController<int>.broadcast();

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
      return Left(
          ServerFailure(message: 'Failed to consume heart: ${e.toString()}'));
    }
  }

  @override
  int getMaxHearts() => _maxHearts;

  @override
  Future<Duration> getTimeToNextHeart() async {
    final timeUntilNext = await getTimeUntilNextRegeneration();
    return timeUntilNext ?? Duration.zero;
  }

  @override
  Future<Either<Failure, void>> addHearts(int amount) async {
    try {
      final box = await heartsBox;
      final currentHearts = await getCurrentHearts();
      final newHearts = (currentHearts + amount).clamp(0, _maxHearts);

      await box.put(_heartsKey, newHearts);
      _heartsController.add(newHearts);

      return const Right(null);
    } catch (e) {
      return Left(
          ServerFailure(message: 'Failed to add hearts: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> regenerateHeart() async {
    try {
      final box = await heartsBox;
      final currentHearts = await getCurrentHearts();

      if (currentHearts < _maxHearts) {
        final newHearts = currentHearts + 1;
        await box.put(_heartsKey, newHearts);

        if (newHearts >= _maxHearts) {
          await box.delete(_lastRegenKey);
        }

        _heartsController.add(newHearts);
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(
          message: 'Failed to regenerate heart: ${e.toString()}'));
    }
  }

  @override
  void startRegenerationTimer() {
    _regenerationTimer?.cancel();
    _regenerationTimer = Timer.periodic(const Duration(minutes: 1), (_) async {
      await _regenerateHearts();
    });
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

  /// Start automatic heart regeneration timer
  Timer? _regenerationTimer;

  void stopRegenerationTimer() {
    _regenerationTimer?.cancel();
    _regenerationTimer = null;
  }

  /// Internal method to handle heart regeneration
  Future<void> _regenerateHearts() async {
    try {
      final box = await heartsBox;
      final currentHearts =
          box.get(_heartsKey, defaultValue: _defaultHearts) as int;

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
      final heartsToRegen =
          (timeSinceLastRegen.inMinutes / _regenerationInterval.inMinutes)
              .floor();

      if (heartsToRegen > 0) {
        final newHearts = (currentHearts + heartsToRegen).clamp(0, _maxHearts);
        await box.put(_heartsKey, newHearts);

        if (newHearts >= _maxHearts) {
          // Remove regeneration timer when at max
          await box.delete(_lastRegenKey);
        } else {
          // Update last regeneration time
          final newLastRegen = lastRegen.add(Duration(
              minutes: heartsToRegen * _regenerationInterval.inMinutes));
          await box.put(_lastRegenKey, newLastRegen.millisecondsSinceEpoch);
        }

        _heartsController.add(newHearts);
      }
    } catch (e) {
      // Handle regeneration errors silently
    }
  }

  /// Dispose resources
  void dispose() {
    stopRegenerationTimer();
    _heartsController.close();
  }
}
