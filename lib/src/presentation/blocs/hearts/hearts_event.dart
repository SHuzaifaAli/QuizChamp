import 'package:equatable/equatable.dart';

abstract class HeartsEvent extends Equatable {
  const HeartsEvent();

  @override
  List<Object?> get props => [];
}

class LoadHearts extends HeartsEvent {
  const LoadHearts();
}

class ConsumeHeart extends HeartsEvent {
  const ConsumeHeart();
}

class AddHearts extends HeartsEvent {
  final int amount;

  const AddHearts(this.amount);

  @override
  List<Object?> get props => [amount];
}

class StartRegeneration extends HeartsEvent {
  const StartRegeneration();
}

class UpdateHeartTimer extends HeartsEvent {
  const UpdateHeartTimer();
}
