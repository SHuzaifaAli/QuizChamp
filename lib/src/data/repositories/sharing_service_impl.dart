import 'package:dartz/dartz.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import '../../domain/repositories/sharing_service.dart';
import '../../core/error/failures.dart';

class SharingServiceImpl implements SharingService {
  static const String _appStoreUrl = 'https://apps.apple.com/app/quizchamp'; // Replace with actual App Store URL
  static const String _playStoreUrl = 'https://play.google.com/store/apps/details?id=com.quizchamp'; // Replace with actual Play Store URL
  static const String _webUrl = 'https://quizchamp.app'; // Replace with actual web URL
  
  final Uuid _uuid = const Uuid();

  @override
  Future<Either<Failure, String>> generateShareableLink() async {
    try {
      final inviteCode = _uuid.v4().substring(0, 8).toUpperCase();
      final shareableLink = '$_webUrl?invite=$inviteCode';
      return Right(shareableLink);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to generate shareable link: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> shareAppLink(String link) async {
    try {
      final message = '''
🎮 Join me on QuizChamp! 🎮

Test your knowledge and challenge friends in exciting quiz battles!

📱 Download now: $link

Use my invite link and let's compete! 🏆
      ''';

      await Share.share(
        message,
        subject: 'Join me on QuizChamp!',
      );
      
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to share app link: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> shareInviteCode(String code) async {
    try {
      final message = '''
🎮 QuizChamp Invite Code 🎮

My invite code: $code

1. Download QuizChamp from your app store
2. Enter this code when prompted
3. Let's start quizzing together! 🧠✨

See you there! 🏆
      ''';

      await Share.share(
        message,
        subject: 'QuizChamp Invite Code: $code',
      );
      
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to share invite code: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> generateInviteCode() async {
    try {
      final code = _uuid.v4().substring(0, 8).toUpperCase();
      return Right(code);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to generate invite code: $e'));
    }
  }

  String getPlatformSpecificUrl() {
    // This would typically use device info to determine platform
    // For now, return a generic URL
    return _webUrl;
  }
}
