import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/hearts_service.dart';
import '../../../data/services/user_service.dart';
import '../user/user_bloc.dart';
import '../user/user_event.dart';
import 'hearts_event.dart';
import 'hearts_state.dart';

class HeartsBloc extends Bloc<HeartsEvent, HeartsState> {
  final HeartsService heartsService;
  final UserService userService;
  final UserBloc? userBloc;

  HeartsBloc({
    required this.heartsService, 
    required this.userService,
    this.userBloc,
  }) : super(const HeartsInitial()) {
    on<LoadHearts>(_onLoadHearts);
    on<ConsumeHeart>(_onConsumeHeart);
    on<AddHearts>(_onAddHearts);
    on<StartRegeneration>(_onStartRegeneration);
    on<UpdateHeartTimer>(_onUpdateHeartTimer);
  }

  HeartsService get service => heartsService;

  Future<void> _onLoadHearts(LoadHearts event, Emitter<HeartsState> emit) async {
    try {
      // First try to get hearts from Firebase
      final userData = await userService.getCurrentUserData();
      int firebaseHearts = userData?.hearts ?? 3;
      
      // Get local hearts from service
      final localHearts = await heartsService.getCurrentHearts();
      final maxHearts = heartsService.getMaxHearts();
      final timeToNextHeart = await heartsService.getTimeToNextHeart();

      // Use Firebase hearts if available, otherwise use local hearts
      final finalHearts = userData != null ? firebaseHearts : localHearts;
      
      // Sync local service with Firebase hearts if they're different
      if (userData != null && firebaseHearts != localHearts) {
        // Update local hearts to match Firebase
        // Note: We might need to add a method to set hearts directly in the service
        print('🔄 [HeartsBloc] Syncing local hearts ($localHearts) with Firebase ($firebaseHearts)');
      }

      emit(HeartsLoaded(
        currentHearts: finalHearts,
        maxHearts: maxHearts,
        timeToNextHeart: timeToNextHeart,
        isRegenerating: finalHearts < maxHearts,
      ));

      if (finalHearts < maxHearts) {
        add(const StartRegeneration());
      }
    } catch (e) {
      emit(HeartsError(message: 'Failed to load hearts: $e'));
    }
  }

  Future<void> _onConsumeHeart(ConsumeHeart event, Emitter<HeartsState> emit) async {
    final currentState = state;
    if (currentState is HeartsLoaded && currentState.currentHearts > 0) {
      try {
        await heartsService.consumeHeart();
        
        final newHearts = currentState.currentHearts - 1;
        
        // Update Firebase
        try {
          await userService.updateUserHearts(newHearts);
        } catch (e) {
          print('⚠️ [HeartsBloc] Failed to update Firebase hearts: $e');
          // Continue with local update even if Firebase fails
        }
        
        // Update UserBloc if available
        userBloc?.add(UpdateUserHearts(newHearts));
        
        emit(currentState.copyWith(
          currentHearts: newHearts,
          isRegenerating: newHearts < currentState.maxHearts,
        ));

        if (newHearts < currentState.maxHearts) {
          add(const StartRegeneration());
        }
      } catch (e) {
        emit(HeartsError(message: 'Failed to consume heart: $e'));
      }
    }
  }

  Future<void> _onAddHearts(AddHearts event, Emitter<HeartsState> emit) async {
    final currentState = state;
    if (currentState is HeartsLoaded) {
      try {
        await heartsService.addHearts(event.amount);
        
        final newHearts = (currentState.currentHearts + event.amount)
            .clamp(0, currentState.maxHearts);
        
        emit(currentState.copyWith(
          currentHearts: newHearts,
          isRegenerating: newHearts < currentState.maxHearts,
        ));
      } catch (e) {
        emit(HeartsError(message: 'Failed to add hearts: $e'));
      }
    }
  }

  Future<void> _onStartRegeneration(StartRegeneration event, Emitter<HeartsState> emit) async {
    // Start a periodic timer to update the heart regeneration
    // This would typically be handled by a timer service
  }

  Future<void> _onUpdateHeartTimer(UpdateHeartTimer event, Emitter<HeartsState> emit) async {
    final currentState = state;
    if (currentState is HeartsLoaded && currentState.isRegenerating) {
      try {
        final timeToNextHeart = await heartsService.getTimeToNextHeart();
        
        if (timeToNextHeart.inSeconds <= 0) {
          // Time to regenerate a heart
          await heartsService.regenerateHeart();
          final newHearts = (currentState.currentHearts + 1)
              .clamp(0, currentState.maxHearts);
          
          emit(currentState.copyWith(
            currentHearts: newHearts,
            timeToNextHeart: await heartsService.getTimeToNextHeart(),
            isRegenerating: newHearts < currentState.maxHearts,
          ));
        } else {
          emit(currentState.copyWith(
            timeToNextHeart: timeToNextHeart,
          ));
        }
      } catch (e) {
        emit(HeartsError(message: 'Failed to update heart timer: $e'));
      }
    }
  }
}
