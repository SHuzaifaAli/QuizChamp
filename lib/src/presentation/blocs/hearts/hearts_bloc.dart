import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/hearts_service.dart';
import 'hearts_event.dart';
import 'hearts_state.dart';

class HeartsBloc extends Bloc<HeartsEvent, HeartsState> {
  final HeartsService heartsService;

  HeartsBloc({required this.heartsService}) : super(const HeartsInitial()) {
    on<LoadHearts>(_onLoadHearts);
    on<ConsumeHeart>(_onConsumeHeart);
    on<AddHearts>(_onAddHearts);
    on<StartRegeneration>(_onStartRegeneration);
    on<UpdateHeartTimer>(_onUpdateHeartTimer);
  }

  HeartsService get service => heartsService;

  Future<void> _onLoadHearts(LoadHearts event, Emitter<HeartsState> emit) async {
    try {
      final hearts = await heartsService.getCurrentHearts();
      final maxHearts = heartsService.getMaxHearts();
      final timeToNextHeart = await heartsService.getTimeToNextHeart();

      emit(HeartsLoaded(
        currentHearts: hearts,
        maxHearts: maxHearts,
        timeToNextHeart: timeToNextHeart,
        isRegenerating: hearts < maxHearts,
      ));

      if (hearts < maxHearts) {
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
