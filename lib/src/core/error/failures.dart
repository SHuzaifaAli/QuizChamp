import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure([this.properties = const <dynamic>[]]);

  final List<dynamic> properties;

  @override
  List<Object> get props => [properties];
}

// General failures
class ServerFailure extends Failure {
  final String message;
  ServerFailure({required this.message}) : super([message]);
}

class CacheFailure extends Failure {}

// Auth failures
class AuthFailure extends Failure {
  final String message;
  AuthFailure({required this.message}) : super([message]);
}

class UserCancelledAuthFailure extends AuthFailure {
  UserCancelledAuthFailure()
      : super(message: 'User cancelled the sign-in process.');
}

class NetworkFailure extends Failure {}

// Enhanced Quiz Engine failures
class InsufficientHeartsFailure extends Failure {
  final int availableHearts;
  InsufficientHeartsFailure({required this.availableHearts}) : super([availableHearts]);
}

class AudioFailure extends Failure {
  final String message;
  AudioFailure({required this.message}) : super([message]);
}

class AnimationFailure extends Failure {
  final String message;
  AnimationFailure({required this.message}) : super([message]);
}

class QuizSessionFailure extends Failure {
  final String message;
  QuizSessionFailure({required this.message}) : super([message]);
}

// Social Features failures
class FriendRequestFailure extends Failure {
  final String message;
  FriendRequestFailure({required this.message}) : super([message]);
}

class ChallengeFailure extends Failure {
  final String message;
  ChallengeFailure({required this.message}) : super([message]);
}

class SocialActivityFailure extends Failure {
  final String message;
  SocialActivityFailure({required this.message}) : super([message]);
}

class ContactsPermissionFailure extends Failure {
  ContactsPermissionFailure() : super(['Contacts permission denied']);
}

class NotificationFailure extends Failure {
  final String message;
  NotificationFailure({required this.message}) : super([message]);
}
