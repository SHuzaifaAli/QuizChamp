import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object> get props => [];
}

class LoadUserData extends UserEvent {
  const LoadUserData();
}

class UpdateUserHearts extends UserEvent {
  final int hearts;

  const UpdateUserHearts(this.hearts);

  @override
  List<Object> get props => [hearts];
}

class UpdateUserPoints extends UserEvent {
  final int points;

  const UpdateUserPoints(this.points);

  @override
  List<Object> get props => [points];
}

class RefreshUserData extends UserEvent {
  const RefreshUserData();
}
