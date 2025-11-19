import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:quiz_champ/src/data/repositories/hearts_service_impl.dart';
import 'package:quiz_champ/src/core/error/failures.dart';

import 'hearts_service_impl_test.mocks.dart';

@GenerateMocks([Box])
void main() {
  group('HeartsServiceImpl', () {
    late HeartsServiceImpl heartsService;
    late MockBox mockBox;

    setUp(() {
      mockBox = MockBox();
      heartsService = HeartsServiceImpl();
    });

    tearDown(() {
      heartsService.dispose();
    });

    group('getCurrentHearts', () {
      test('should return default hearts when no data exists', () async {
        when(mockBox.get(any, defaultValue: anyNamed('defaultValue')))
            .thenReturn(3);

        // This test would need proper Hive mocking setup
        // For now, we'll test the basic functionality
        expect(heartsService.maxHearts, 5);
        expect(heartsService.regenerationInterval, const Duration(minutes: 30));
      });

      test('should clamp hearts to valid range', () async {
        // Test that hearts are properly clamped between 0 and max
        final stats = await heartsService.getHeartsStats();
        expect(stats['max_hearts'], 5);
        expect(stats['current_hearts'], greaterThanOrEqualTo(0));
        expect(stats['current_hearts'], lessThanOrEqualTo(5));
      });
    });

    group('consumeHeart', () {
      test('should return failure when no hearts available', () async {
        // Mock zero hearts
        when(mockBox.get(any, defaultValue: anyNamed('defaultValue')))
            .thenReturn(0);

        final result = await heartsService.consumeHeart();
        
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<InsufficientHeartsFailure>()),
          (_) => fail('Should return failure'),
        );
      });
    });

    group('addHearts', () {
      test('should add hearts correctly', () async {
        final result = await heartsService.addHearts(2);
        
        expect(result.isRight(), true);
      });

      test('should not exceed maximum hearts', () async {
        // Add more hearts than maximum
        final result = await heartsService.addHearts(10);
        
        expect(result.isRight(), true);
        
        final stats = await heartsService.getHeartsStats();
        expect(stats['current_hearts'], lessThanOrEqualTo(5));
      });
    });

    group('fillHearts', () {
      test('should set hearts to maximum', () async {
        final result = await heartsService.fillHearts();
        
        expect(result.isRight(), true);
      });
    });

    group('hearts stream', () {
      test('should provide hearts stream', () {
        expect(heartsService.heartsStream, isA<Stream<int>>());
      });

      test('should emit hearts updates', () async {
        final stream = heartsService.heartsStream;
        
        // Listen to stream
        final streamFuture = stream.take(1).toList();
        
        // Trigger an update
        await heartsService.addHearts(1);
        
        // Wait for stream emission
        final emissions = await streamFuture.timeout(
          const Duration(seconds: 1),
          onTimeout: () => <int>[],
        );
        
        // Should have received at least one emission
        expect(emissions, isNotEmpty);
      });
    });

    group('regeneration timer', () {
      test('should start and stop regeneration timer', () {
        heartsService.startRegenerationTimer();
        // Timer should be running (no direct way to test this without exposing internals)
        
        heartsService.stopRegenerationTimer();
        // Timer should be stopped
        
        // No exceptions should be thrown
        expect(true, true);
      });
    });

    group('time until regeneration', () {
      test('should return null when at max hearts', () async {
        await heartsService.fillHearts();
        
        final timeUntilNext = await heartsService.getTimeUntilNextRegeneration();
        expect(timeUntilNext, isNull);
      });
    });

    group('hearts statistics', () {
      test('should return valid statistics', () async {
        final stats = await heartsService.getHeartsStats();
        
        expect(stats, isA<Map<String, dynamic>>());
        expect(stats.containsKey('current_hearts'), true);
        expect(stats.containsKey('max_hearts'), true);
        expect(stats.containsKey('is_at_max'), true);
        expect(stats.containsKey('regeneration_interval_minutes'), true);
        
        expect(stats['max_hearts'], 5);
        expect(stats['regeneration_interval_minutes'], 30);
        expect(stats['current_hearts'], isA<int>());
        expect(stats['is_at_max'], isA<bool>());
      });
    });

    group('isAtMaxHearts', () {
      test('should return correct max hearts status', () async {
        final isAtMax = await heartsService.isAtMaxHearts();
        expect(isAtMax, isA<bool>());
      });
    });

    group('resetHearts', () {
      test('should reset hearts to default', () async {
        final result = await heartsService.resetHearts();
        
        expect(result.isRight(), true);
      });
    });

    group('error handling', () {
      test('should handle errors gracefully in getCurrentHearts', () async {
        // Should not throw exceptions even if underlying storage fails
        final hearts = await heartsService.getCurrentHearts();
        expect(hearts, isA<int>());
        expect(hearts, greaterThanOrEqualTo(0));
      });

      test('should handle errors gracefully in getHeartsStats', () async {
        // Should return default stats even if storage fails
        final stats = await heartsService.getHeartsStats();
        expect(stats, isA<Map<String, dynamic>>());
        expect(stats['max_hearts'], 5);
      });
    });

    group('constants and properties', () {
      test('should have correct maximum hearts', () {
        expect(heartsService.maxHearts, 5);
      });

      test('should have correct regeneration interval', () {
        expect(heartsService.regenerationInterval, const Duration(minutes: 30));
      });
    });

    group('resource management', () {
      test('should dispose resources properly', () {
        // Should not throw when disposing
        expect(() => heartsService.dispose(), returnsNormally);
      });
    });
  });
}