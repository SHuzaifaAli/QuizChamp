import 'lib/src/data/repositories/hearts_service_impl.dart';
import 'lib/src/domain/repositories/hearts_service.dart';

void main() {
  HeartsService heartsService = HeartsServiceImpl();
  
  print('Testing HeartsService implementation...');
  
  // Test getMaxHearts
  try {
    int maxHearts = heartsService.getMaxHearts();
    print('✓ getMaxHearts() works: $maxHearts');
  } catch (e) {
    print('✗ getMaxHearts() failed: $e');
  }
  
  // Test getTimeToNextHeart
  try {
    heartsService.getTimeToNextHeart().then((duration) {
      print('✓ getTimeToNextHeart() works: $duration');
    }).catchError((e) {
      print('✗ getTimeToNextHeart() failed: $e');
    });
  } catch (e) {
    print('✗ getTimeToNextHeart() failed: $e');
  }
  
  // Test startRegenerationTimer
  try {
    heartsService.startRegenerationTimer();
    print('✓ startRegenerationTimer() works');
  } catch (e) {
    print('✗ startRegenerationTimer() failed: $e');
  }
  
  // Test regenerateHeart
  try {
    heartsService.regenerateHeart().then((result) {
      print('✓ regenerateHeart() works: $result');
    }).catchError((e) {
      print('✗ regenerateHeart() failed: $e');
    });
  } catch (e) {
    print('✗ regenerateHeart() failed: $e');
  }
  
  print('Test completed.');
}
