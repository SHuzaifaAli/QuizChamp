import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';

enum NotificationType {
  friendRequest,
  friendRequestAccepted,
  challengeReceived,
  challengeCompleted,
  friendAchievement,
}

class NotificationData {
  final NotificationType type;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final String? imageUrl;

  NotificationData({
    required this.type,
    required this.title,
    required this.body,
    required this.data,
    this.imageUrl,
  });
}

abstract class NotificationService {
  Future<Either<Failure, void>> sendNotification(String userId, NotificationData notification);
  Future<Either<Failure, void>> sendBulkNotifications(List<String> userIds, NotificationData notification);
  Future<Either<Failure, String?>> getDeviceToken();
  Future<Either<Failure, void>> updateDeviceToken(String userId, String token);
  Future<Either<Failure, void>> subscribeToTopic(String topic);
  Future<Either<Failure, void>> unsubscribeFromTopic(String topic);
  Stream<NotificationData> get notificationStream;
}