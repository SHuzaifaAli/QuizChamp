import 'package:equatable/equatable.dart';

abstract class HeartsState extends Equatable {
  const HeartsState();

  @override
  List<Object?> get props => [];
}

class HeartsInitial extends HeartsState {
  const HeartsInitial();
}

class HeartsLoading extends HeartsState {
  const HeartsLoading();
}

class HeartsLoaded extends HeartsState {
  final int currentHearts;
  final int maxHearts;
  final Duration timeToNextHeart;
  final bool isRegenerating;

  const HeartsLoaded({
    required this.currentHearts,
    required this.maxHearts,
    required this.timeToNextHeart,
    required this.isRegenerating,
  });

  HeartsLoaded copyWith({
    int? currentHearts,
    int? maxHearts,
    Duration? timeToNextHeart,
    bool? isRegenerating,
  }) {
    return HeartsLoaded(
      currentHearts: currentHearts ?? this.currentHearts,
      maxHearts: maxHearts ?? this.maxHearts,
      timeToNextHeart: timeToNextHeart ?? this.timeToNextHeart,
      isRegenerating: isRegenerating ?? this.isRegenerating,
    );
  }

  @override
  List<Object?> get props => [
        currentHearts,
        maxHearts,
        timeToNextHeart,
        isRegenerating,
      ];
}

class HeartsError extends HeartsState {
  final String message;

  const HeartsError({required this.message});

  @override
  List<Object?> get props => [message];
}
